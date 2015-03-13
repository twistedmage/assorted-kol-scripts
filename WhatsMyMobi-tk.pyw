#!/usr/bin/env python
# vim:fileencoding=UTF-8:ts=4:sw=4:sta:et:sts=4:ai

import sys, os, struct
import Tkinter, Tkconstants, tkFileDialog, tkMessageBox, tkFont
import time, threading, Queue

os.environ['PYTHONIOENCODING'] = "utf-8"
MOBI_FORMATS = ['mobi', 'azw', 'azw3', 'azw4', 'prc']
RETURN_CODE_MAP = {
	0 : 'not a valid MOBI file',
	1 : 'a TEXtREAd ebook',
	2 : 'a Topaz ebook',
	3 : 'a Print Replica (fixed-layout) ebook',
	4 : 'a KF8-only ebook',
	5 : 'a joint MOBI/KF8 ebook',
	6 : 'a MOBI-only ebook',
}

# Temporary file for "remembering" last directory.
if sys.platform.startswith('win'):
	WORKING_DIR_FILE = '~tmpmobidir'
else:
	WORKING_DIR_FILE = '.tmpmobidir'

class Sectionizer:
	""" Stolen from Mobi_Unpack and slightly modified. """
	def __init__(self, filename_or_stream):
		if hasattr(filename_or_stream, 'read'):
			print 'Stream'
			self.stream = filename_or_stream
			self.stream.seek(0)
		else:
			self.stream = open(filename_or_stream, 'rb')
		if self.stream.read(3) == 'TPZ':
			self.ident = 'TPZ'
		else:
			self.stream.seek(0)
			header = self.stream.read(78)
			self.ident = header[0x3C:0x3C+8]
		try:
			self.num_sections, = struct.unpack_from('>H', header, 76)
		except:
			return
		sections = self.stream.read(self.num_sections*8)
		try:
			self.sections = struct.unpack_from('>%dL' % (self.num_sections*2), sections, 0)[::2] + (0xfffffff, )
		except:
			pass

	def loadSection(self, section):
		before, after = self.sections[section:section+2]
		self.stream.seek(before)
		return self.stream.read(after - before)
		
class MobiHeader:
	""" Stolen from Mobi_Unpack and slightly modified. """
	def __init__(self, sect, sectNumber):
		self.sect = sect
		self.start = sectNumber
		self.header = self.sect.loadSection(self.start)
		self.records, = struct.unpack_from('>H', self.header, 0x8)
		self.length, self.type, self.codepage, self.unique_id, self.version = struct.unpack('>LLLLL', self.header[20:40])
		self.mlstart = self.sect.loadSection(self.start+1)[0:4]

	def isPrintReplica(self):
		return self.mlstart[0:4] == "%MOP"

	def hasKF8(self):
		return self.start != 0 or self.version == 8
	
	def isJointFile(self):
		# Check for joint MOBI/KF8
		for i in xrange(len(self.sect.sections)-1):
			before, after = self.sect.sections[i:i+2]
			if (after - before) == 8:
				data = self.sect.loadSection(i)
				if data == 'BOUNDARY':
					return True
					break
		return False

class WorkerThread(threading.Thread):
	""" Worker thread for the processQueues function.
	Overkill?? You bet, but it seemed a perfect time to attempt
	to get a handle on Python threading and queuing. :-)"""
	def __init__(self, file_q, parse_q):
		super(WorkerThread, self).__init__()
		self.file_q = file_q
		self.parse_q = parse_q
		self.stoprequest = threading.Event()

	def run(self):
		""" As long as we weren't asked to stop, try to take new tasks from the
		queue. The tasks are taken with a blocking 'get', so no CPU cycles are wasted
		while waiting. Also, 'get' is given a timeout, so stoprequest is always checked,
		even if there's nothing in the queue. """
		while not self.stoprequest.isSet():
			try:
				mobi = self.file_q.get(True, 0.05)
				self.parse_q.put((mobi, self.getMobiInfo(mobi)))
			except Queue.Empty:
				continue

	def join(self, timeout=None):
		self.stoprequest.set()
		super(WorkerThread, self).join(timeout)
		
	def getMobiInfo(self, mobi):
		""" Returns a numerical code representing the MOBI "sub-type". """
		sect = Sectionizer(mobi)
		if sect.ident != 'BOOKMOBI' and sect.ident != 'TEXtREAd' and sect.ident !='TPZ':
			return 0 #'Invalid file format'
		if sect.ident == 'TEXtREAd':
			return 1 #'TEXtREAd'
		if sect.ident =='TPZ':
			return 2 #'Topaz'
		try:
			mh = MobiHeader(sect,0)
		except Exception, e:
			print str(e)
			return 0 #'Invalid file format'
		if mh.isPrintReplica():
			return 3 #'Print Replica'
		if mh.hasKF8():
			# if this is a mobi8-only file hasKF8 here will be true
			return 4 #'KF8-only'
		if mh.isJointFile():
			return 5 #'joint MOBI/KF8'
		return 6 #'MOBI-only'

class guiMain(Tkinter.Frame):
	def __init__(self, parent):
		Tkinter.Frame.__init__(self, parent, border=5)
		
		self.parent = parent        
		self.initUI()

	def initUI(self):
		""" Build the GUI and assign variables and handler functions to elements. """
		self.parent.title('What\'s My MOBI?')
		self.normalFont = tkFont.Font(size=9, weight=tkFont.NORMAL)
		self.boldFont = tkFont.Font(size=10, weight=tkFont.BOLD)
		self.payloadFont = tkFont.Font(size=9, weight=tkFont.NORMAL, underline=True)
		
		body = Tkinter.Frame(self)
		body.pack(fill=Tkconstants.BOTH, expand=True)
		
		status_text = 'Select MOBI file(s) (' + ', '.join(MOBI_FORMATS).upper() + ')'
		self.status = Tkinter.Label(body, text=status_text)
		self.status.pack(side=Tkconstants.TOP, fill=Tkconstants.X)

		chk_frame1 = Tkinter.Frame(body)
		self.openDirvar = Tkinter.IntVar()
		dir_checkbox = Tkinter.Checkbutton(chk_frame1, text="Directory Mode", command=self.directoryClicked, variable=self.openDirvar)
		dir_checkbox.pack(side=Tkconstants.LEFT, fill=Tkconstants.X)
		chk_frame1.pack(fill=Tkconstants.X)

		chk_frame2 = Tkinter.Frame(body)
		self.Recursevar = Tkinter.IntVar()
		self.recurse_checkbox = Tkinter.Checkbutton(chk_frame2, text="Recurse Subdirectories", variable=self.Recursevar)
		self.recurse_checkbox.pack(side=Tkconstants.LEFT, fill=Tkconstants.X)
		chk_frame2.pack(fill=Tkconstants.X)
		self.recurse_checkbox.config(state="disabled")

		entry_frame = Tkinter.Frame(body)
		self.textPath = Tkinter.Entry(entry_frame)
		self.textPath.pack(side=Tkconstants.LEFT, fill=Tkconstants.X, expand=True)
		button = Tkinter.Button(entry_frame, text="...", command=self.fileChooser)
		button.pack(side=Tkconstants.RIGHT, fill=Tkconstants.X)
		entry_frame.pack(fill=Tkconstants.X)

		scroll_frame = Tkinter.Frame(body)
		scrollbar = Tkinter.Scrollbar(scroll_frame, orient="vertical")
		self.stext = Tkinter.Text(scroll_frame, yscrollcommand=scrollbar.set,
								  bd=5, relief=Tkconstants.RIDGE, wrap=Tkconstants.WORD)
		scrollbar.config(command=self.stext.yview)
		scrollbar.pack(side=Tkconstants.RIGHT, fill=Tkconstants.Y)
		self.stext.pack(side=Tkconstants.LEFT, fill=Tkconstants.BOTH, expand=True)
		scroll_frame.pack(fill=Tkconstants.BOTH, expand=True)
		
		buttons = Tkinter.Frame(body)
		buttons.pack(side=Tkconstants.BOTTOM)
		self.gbutton = Tkinter.Button(
			buttons, text="Process", width=10, command=self.gatherFiles)
		self.gbutton.pack(side=Tkconstants.LEFT)
		
		self.cbutton = Tkinter.Button(
			buttons, text="Clear Log", width=10, command=self.clear)
		self.cbutton.pack(side=Tkconstants.LEFT)
		
		self.qbutton = Tkinter.Button(
			buttons, text="Quit", width=10, command=self.quit)
		self.qbutton.pack(side=Tkconstants.RIGHT)

	def gatherFiles(self):
		""" This is the meat and the potatoes. Does the best job it can
		to round up all the mobi files that the user wants to query. If you 
		try really hard to break it ... I'm almost positive you'll succeed. """
		self.PROCESS_LIST = []
		self.RECURSE = False
		#self.clear()
		mobiSelections = []
		if self.textPath.get() != '':
			mobiSelections = self.textPath.get().strip().strip(';').split(';')
		mobiSelections = [s.lstrip() for s in mobiSelections]
		if mobiSelections:
			# Try to write the most recently used directory to the temp file for the next run.
			if os.path.isdir(mobiSelections[0]):
				dir_name = mobiSelections[0]
			else:
				dir_name = os.path.dirname(mobiSelections[0])
			try:
				file(os.path.join(os.getcwd(), WORKING_DIR_FILE), 'w').write(dir_name)
			except Exception, e:
				print str(e)
				pass
			for index, inpath in enumerate(mobiSelections):
				if not inpath or not os.path.exists(inpath):
					self.showCmdOutput('Error: Specified input %s does not exist! Skipping it.\n' % inpath, None, 'error')
					mobiSelections.pop(index)
					continue
				if (inpath and os.path.isfile(inpath) and
								os.path.splitext(inpath)[1].lower().strip('.') not in MOBI_FORMATS):
					self.showCmdOutput('Error: Specified input %s is not a recognized MOBI file! Skipping it.\n' % inpath, None, 'error')
					mobiSelections.pop(index)
					continue
				if not self.openDirvar.get() and os.path.isdir(inpath):
					self.showCmdOutput('Error: %s is not a file! Skipping it.\n' % inpath, None, 'error')
					mobiSelections.pop(index)
					continue
				if self.openDirvar.get() and not os.path.isdir(inpath):
					self.showCmdOutput('Error: %s is not a directory! Skipping it.\n' % inpath, None, 'error')
					mobiSelections.pop(index)
					continue
		else:
			self.showMsgBox('Error!', 'No specified input.')
			return

		if mobiSelections:
			# Note the start time
			self.start_time = time.time()
			# Gather all mobi-type files in this directory and all subdirectories
			if self.openDirvar.get() and self.Recursevar.get():
				self.RECURSE = True
				""" It's _should_ be only ONE directory at this point (unless the user did something
				funky and manually typed two directories in the textbox), but it's still
				in a python List, so only  grab the first element of the list. """
				self.PROCESS_LIST.extend(list(self.walkPathRecursive(mobiSelections[0])))
			# Gather all mobi-type files in this directory
			elif self.openDirvar.get():
				self.RECURSE = False
				# Same stipulation as above.
				self.PROCESS_LIST.extend(list(self.walkPath(mobiSelections[0])))
			else:
				# At this point, it's a file list ... even if there's only one file in it.
				self.PROCESS_LIST.extend(mobiSelections)
		
		""" If there's any MOBIs to process ... do so.
		Otherwise indicate there's nothing to do. """
		if self.PROCESS_LIST:
			self.showCmdOutput('Starting...\n', None, 'header')
			self.processQueues()
		else:
			self.showMsgBox('Error!', 'No MOBI files found to Process!')

	def processQueues(self):
		""" Create the thread pools and wait for them to finish. """
		file_q = Queue.Queue()
		parse_q = Queue.Queue()
	
		# Create the "thread pool"
		pool = [WorkerThread(file_q=file_q, parse_q=parse_q) for i in range(4)]
	
		# Start all threads
		for thread in pool:
			thread.start()
	
		# Load the input queue
		work_count = 0
		for mobi in self.PROCESS_LIST:
			work_count += 1
			file_q.put(mobi)
		mobi_count = work_count
		
		 # Now get all the results and print them out
		while work_count > 0:
			result = parse_q.get()
			if self.RECURSE:
				msg1 = '%s is ' % result[0]
				msg2 = '%s.\n' % RETURN_CODE_MAP[result[1]]
			else:
				msg1 = '%s is ' % os.path.basename(result[0])
				msg2 = '%s.\n' % RETURN_CODE_MAP[result[1]]
			self.showCmdOutput(msg1, msg2, 'default')
			work_count -= 1
			
		# Ask threads to die and wait for them to do it
		for thread in pool:
			thread.join()
		
		msg	= '\nDone processing %d files.\nElapsed time: %s seconds.\n\n' % (mobi_count, time.time() - self.start_time)
		self.showCmdOutput(msg, None, 'special')

	def fileChooser(self):
		""" Create the dialog that allows the user to select files/directories. """
		wd = os.getcwd()
		f = os.path.join(os.getcwd(), WORKING_DIR_FILE)
		if os.path.exists(f):
			try:
				wd = file(f,'rb').read()
			except:
				wd = os.getcwd()
				pass
		file_opt = {}
		file_opt['parent'] = None
		file_opt['initialdir'] = wd
		if not self.openDirvar.get():
			# Use file dialog.
			file_opt['title']= 'Select MOBI file'
			file_opt['defaultextension'] = '.mobi'
			file_opt['multiple'] = True
			extensions = ' '.join(['.' + ext for ext in MOBI_FORMATS])
			file_opt['filetypes'] = [('MOBI files', extensions), ('All files', '.*')]
			inpath = self.fixlist(tkFileDialog.askopenfilenames(**file_opt))
		else:
			# Use directory dialog.
			file_opt['mustexist'] = True
			file_opt['title']= 'Select Directory'
			inpath = [tkFileDialog.askdirectory(**file_opt)]
		if inpath and inpath !=[''] and inpath != [()]:
			""" Write a semi-colon delimited list of the files selected to
			the gui textbox. If filenames have semi-colons in them, it's  
			going to barf really hard when they get read back in. """
			self.textPath.delete(0, Tkconstants.END)
			show_path = ''
			for path in inpath:
				if path != '':
					show_path += os.path.normpath(path) + '; '
			self.textPath.insert(0, show_path.rstrip('; '))

	def directoryClicked(self):
		""" Directory checkbox clicked, activate/deactivate
		the Recurse checkbox and clear the textbox as necessary. """
		self.textPath.delete(0, Tkconstants.END)
		if self.openDirvar.get():
			self.status.config(text = 'Select Directory to search')
			self.recurse_checkbox.configure(state="normal")
		else:
			self.status.config(text = 'Select MOBI file (' + ', '.join(MOBI_FORMATS).upper() + ')')
			self.recurse_checkbox.deselect()
			self.recurse_checkbox.configure(state="disabled")
		return

	def clear(self):
		"""Clear the scrolling textbox."""
		self.stext.delete("1.0", Tkconstants.END)
		return
	
	def fixlist(self, filenames):
		""" Tkinter has its own interpretations of what a "list" is on different OSs.
		Which is what tkFileDialog.askopenfilenames is supposed to return.
		This routine attempts to massage all output into a proper python list, regardless of the OS. """
		import re
		
		# Do nothing if already a python list
		if isinstance(filenames,list): return filenames
		# Linux tkFileDialog.askopenfilenames seems to return a tuple. 
		if isinstance(filenames,tuple): return list(filenames)
	
		""" Windows tkFileDialog.askopenfilenames seems to return a string containing multiple filenames.
		The re should match: {text and white space in brackets} AND anynonwhitespacetokens
		*? is a non-greedy match for any character sequence
		\S is non white space. """		
		result = re.findall("{.*?}|\S+",filenames)
		#remove any {} characters from the start and end of the file names
		result = [ re.sub("^{|}$","",i) for i in result ]
	
		return result

	def showCmdOutput(self, msg1, msg2=None, tag='default'):
		""" Write message to the scrolling textbox. """
		self.stext.tag_config('default', lmargin1=10, lmargin2=30, spacing1=3, font=self.normalFont)
		self.stext.tag_config('header', spacing1=5, spacing3=5, font=self.boldFont)
		self.stext.tag_config('error', spacing1=5, spacing3=5, font=self.normalFont, foreground="red")
		self.stext.tag_config('payload', lmargin1=10, lmargin2=30, spacing1=5, spacing3=5, font=self.payloadFont)
		self.stext.tag_config('special', spacing1=0, spacing3=0, font=self.boldFont)

		self.stext.insert(Tkconstants.END, msg1, tag)
		if msg2 is not None:
			self.stext.insert(Tkconstants.END, msg2, 'payload')
		self.stext.yview_pickplace(Tkconstants.END)
		return
	
	def showMsgBox(self, title, msg, icon='error', type='ok'):
		""" Pop a message/warning dialog. """
		msg_opt = {}
		msg_opt['icon'] = icon
		msg_opt['type'] = type
		msg_opt['parent'] = self.parent
		tkMessageBox.showerror(title, msg.encode('utf-8'), **msg_opt)
		return
	
	def walkPathRecursive(self, inpath):
		""" Round up files in directory and all subdirectories. """
		for path, dirs, files in os.walk(inpath):
			for file in files:
				if os.path.splitext(file)[1].lower().strip('.') in MOBI_FORMATS: 
					yield os.path.join(path, file)
					
	def walkPath(self, inpath):
		""" Round up files in directory. """
		files = os.listdir(inpath)
		for file in files:
			if os.path.splitext(file)[1].lower().strip('.') in MOBI_FORMATS: 
					yield os.path.join(inpath, file)

if __name__ == '__main__':
	root = Tkinter.Tk()
	root.title('What\'s My MOBI?')
	root.minsize(500, 500)
	root.resizable(True, True)
	guiMain(root).pack(fill=Tkconstants.BOTH, expand=True)
	root.mainloop()