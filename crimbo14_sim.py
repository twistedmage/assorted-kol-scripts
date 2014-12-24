# -*- coding: utf-8 -*-
"""
Created on Wed Dec 17 12:01:14 2014

@author: Simon
"""
import itertools
import random
import math

pref_schems=True

class bot_skill:
    def __init__(self, pow_attack=0, blam=0, zap=0, run=0, roll=0,
                 hover=0, lube=0, shield=0, light=0, pinch=0, freeze=0,
                 decode=0,burn=0):
        self.pow_attack = pow_attack
        self.blam = blam
        self.zap = zap
        self.run = run
        self.roll = roll
        self.hover = hover
        self.lube = lube
        self.shield = shield
        self.light = light
        self.pinch = pinch
        self.freeze = freeze
        self.decode = decode
        self.burn = burn
    
    def __add__(A,B):
        return bot_skill(A.pow_attack+B.pow_attack, A.blam+B.blam, A.zap+B.zap,
                         A.run+B.run, A.roll+B.roll, A.hover+B.hover,
                         A.lube+B.lube, A.shield+B.shield, A.light+B.light,
                         A.pinch+B.pinch, A.freeze+B.freeze, A.decode+B.decode, A.burn+B.burn)
        
    def __str__(self):
        return "pow_attack="+str(self.pow_attack) \
        +"\nblam="+str(self.blam ) \
        +"\nzap="+str(self.zap ) \
        +"\nrun="+str(self.run) \
        +"\nroll="+str(self.roll) \
        +"\nhover="+str(self.hover) \
        +"\nlube="+str(self.lube) \
        +"\nshield="+str(self.shield) \
        +"\nlight="+str(self.light) \
        +"\npinch="+str(self.pinch) \
        +"\nfreeze="+str(self.freeze)\
        +"\ndecode="+str(self.decode)\
        +"\nburn="+str(self.burn)
        
    def __repr__(self):
        return "pow_attack="+str(self.pow_attack) \
        +"\nblam="+str(self.blam ) \
        +"\nzap="+str(self.zap ) \
        +"\nrun="+str(self.run) \
        +"\nroll="+str(self.roll) \
        +"\nhover="+str(self.hover) \
        +"\nlube="+str(self.lube) \
        +"\nshield="+str(self.shield) \
        +"\nlight="+str(self.light) \
        +"\npinch="+str(self.pinch) \
        +"\nfreeze="+str(self.freeze)\
        +"\ndecode="+str(self.decode)\
        +"\nburn="+str(self.burn)


def max_bs(A,B):
    return bot_skill(max(A.pow_attack,B.pow_attack),
                     max(A.blam,B.blam),
                     max(A.zap,B.zap),
                     max(A.run,B.run),
                     max(A.roll,B.roll),
                     max(A.hover,B.hover),
                     max(A.lube,B.lube),
                     max(A.shield,B.shield),
                     max(A.light,B.light),
                     max(A.pinch,B.pinch),
                     max(A.freeze,B.freeze),
                     max(A.decode,B.decode),
                     max(A.burn,B.burn))
        

        

class bot_piece:
    def __init__(self, ID, slot, name, pow_attack=0, blam=0, zap=0, run=0, roll=0,
                 hover=0, lube=0, shield=0, light=0, pinch=0, freeze=0, decode=0,burn=0):
        self.ID = ID
        self.slot = slot
        self.name = name
        self.bs = bot_skill(pow_attack, blam, zap, run, roll, hover, lube, 
                            shield, light, pinch, freeze, decode,burn)
        
    def __str__(self):
        return self.slot + " = " + self.name +" ("+ str(self.ID)+")"
        
    def __repr__(self):
        return self.slot + " = " + self.name +" ("+ str(self.ID)+")"
    
    def __add__(A,B):
        return bot_piece(-1, "comb", "comb", A.bs.pow_attack+B.bs.pow_attack, A.bs.blam+B.bs.blam,
                         A.bs.zap+B.bs.zap, A.bs.run+B.bs.run, A.bs.roll+B.bs.roll, A.bs.hover+B.bs.hover,
                         A.bs.lube+B.bs.lube, A.bs.shield+B.bs.shield, A.bs.light+B.bs.light,
                         A.bs.pinch+B.bs.pinch, A.bs.freeze+B.bs.freeze, A.bs.decode+B.bs.decode, A.bs.burn+B.bs.burn)
        

class adv:
    def __init__(self, name, choices,  elf_items=[], schematics=[]):
        self.name = name
        self.choices = choices
        self.elf_items=elf_items
        self.schematics=schematics
    def __str__(self):
        return self.name
        
    def __repr__(self):
        return self.name
        
        
def best_solution(gear, adv, mandatory):
    skills = gear.bs
    best_dmg=1000.0
    best_elf_items=0.0
    best_schematics=0.0
    for idx,solution in enumerate(adv.choices):
        solution=max_bs(solution,mandatory)
        # can we actualle do this solution in this gear
        if (solution.pow_attack > skills.pow_attack or solution.blam > skills.blam  or 
            solution.zap > skills.zap or solution.run > skills.run or 
            solution.roll > skills.roll or solution.hover > skills.hover or 
            solution.lube > skills.lube or solution.light > skills.light or
            solution.pinch > skills.pinch or solution.freeze> skills.freeze or 
            solution.decode > skills.decode or solution.burn > skills.burn):
            continue
        
        dmg = math.floor(solution.shield)
        if random.random() < solution.shield%1:
            dmg+=1
        new_elf_items = 0
        new_schematics = 0
        if not len(adv.elf_items)==0:
            new_elf_items=adv.elf_items[idx]
        if not len(adv.schematics)==0:
            new_schematics=adv.schematics[idx]
        if (not pref_schems) and ((dmg<best_dmg) or (dmg==best_dmg and new_elf_items > best_elf_items) or \
           (dmg==best_dmg and new_elf_items==best_elf_items and new_schematics>best_schematics)):
            best_dmg = dmg
            best_elf_items=new_elf_items
            best_schematics=new_schematics
        if pref_schems and ((dmg<best_dmg) or (dmg==best_dmg and new_schematics > best_schematics) or \
           (dmg==best_dmg and new_elf_items>best_elf_items and new_schematics==best_schematics)):
            best_dmg = dmg
            best_elf_items=new_elf_items
            best_schematics=new_schematics
            
    return best_dmg, best_elf_items, best_schematics
    
    
def test_gear_on_advs(gear,advs):
    for adv in advs:
        new_dmg, new_elf_items, new_schematics = best_solution(gear, adv, bot_skill())        
        print adv
        if new_dmg>0:
            print "\tdmg=",new_dmg
        if new_elf_items>0:
            print "\telf=",new_elf_items
        if new_schematics>0:
            print "\tschem=",new_schematics
        

def run_simulations(gear, advs, mandatory):
    elf_items=0.0
    schematics=0.0
    num_sims=1000.0
    for sim in range(int(num_sims)):
        dmg=0
        while dmg < gear.bs.shield:
            adv = random.choice(advs)
            new_dmg, new_elf_items, new_schematics = best_solution(gear, adv, mandatory)
            dmg+=new_dmg
            elf_items+=new_elf_items
            schematics+=new_schematics
        
    elf_items/=num_sims
    schematics/=num_sims
            
    return elf_items,schematics
    
    
def try_permutations(all_pieces, advs, mandatory):
    best_pieces=[]
    best_elf_items=0
    best_schematics=0
    perm=0
    num_perm = len(all_pieces[0])*len(all_pieces[1])*len(all_pieces[2])*len(all_pieces[3])
    for left_piece in all_pieces[0]:
        for right_piece in all_pieces[1]:
            for torso_piece in all_pieces[2]:
                for propulsion_piece in all_pieces[3]:
                    random.seed(101)
                    perm+=1
                    if perm%100==0:
                        print "permutation",perm,"of",num_perm
                    
                    new_elf_items,new_schematics = run_simulations(left_piece + right_piece + torso_piece + propulsion_piece, advs, mandatory)
        
                    if (not pref_schems) and ((new_elf_items > best_elf_items) or \
                       (new_elf_items==best_elf_items and new_schematics>best_schematics)):
                        best_elf_items=new_elf_items
                        best_schematics=new_schematics
                        best_pieces=[left_piece, right_piece, torso_piece, propulsion_piece]
                    if pref_schems and ((new_schematics > best_schematics) or \
                       (new_elf_items>best_elf_items and new_schematics==best_schematics)):
                        best_elf_items=new_elf_items
                        best_schematics=new_schematics
                        best_pieces=[left_piece, right_piece, torso_piece, propulsion_piece]
    
    print("Best set gives average ", best_elf_items, "elf items and average", best_schematics, "schematics")
    print("\nbest set is:", best_pieces)
    print("\nbest set skills:", (best_pieces[0]+best_pieces[1]+best_pieces[2]+best_pieces[3]).bs)    
    return best_pieces
    
    
def get_all_pieces():
    left=[]
    left.append(bot_piece(11, "left", "Camera Claw", decode=1, pinch=1))
    left.append(bot_piece(10, "left", "Bit Masher", decode=1, pow_attack=1))
    left.append(bot_piece(9, "left", "Maxi-Mag Lite", light=2, pow_attack=1))
    #left.append(bot_piece(8, "left", "Data Analyzer", decode=1))
    left.append(bot_piece(7, "left", "Swiss Arm", blam=1, zap=1, pow_attack=1))
    left.append(bot_piece(6, "left", "Mobile Girder", shield=3))
    left.append(bot_piece(5, "left", "mega vise", pow_attack=2)) 
    #left.append(bot_piece(4, "left", "rivet shocker", pow_attack=1, zap=1)) 
    #left.append(bot_piece(3, "left", "rodent gun", blam=1))
    left.append(bot_piece(2, "left", "bug zapper", zap=1, shield=1))
    #left.append(bot_piece(1, "left", "tiny fist", pow_attack=1))
    
    right=[]	
    right.append(bot_piece(11, "right", "Lamp Filler", lube=1, burn=1))
    right.append(bot_piece(10, "right", "Candle Lighter", burn=1))
    right.append(bot_piece(9, "right", "Cold Shoulder", freeze=1, pow_attack=1))
    #right.append(bot_piece(8, "right", "Snow Blower", freeze=1))
    right.append(bot_piece(7, "right", "Grease / Regular Gun", lube=1, blam=1))
    #right.append(bot_piece(6, "right", "Grease Gun", lube=1))
    right.append(bot_piece(5, "right", "Power Stapler", pinch=1, zap=1))
    #right.append(bot_piece(4, "right", "Ribbon Manipulator", pinch=1))
    right.append(bot_piece(3, "right", "Wrecking Ball", pow_attack=1, shield=1))
    #right.append(bot_piece(2, "right", "Power Arm", zap=1))
    #right.append(bot_piece(1, "right", "Ball-Bearing Dispenser", blam=1))
 
    torso=[]
    torso.append(bot_piece(11, "torso", "Refrigerator Chassis", shield=5, freeze=1, light=1))
    torso.append(bot_piece(10, "torso", "Nerding Module", shield=5, decode=1))
    #torso.append(bot_piece(9, "torso", "Really Big Head", shield=5))
    #torso.append(bot_piece(8, "torso", "Cyclopean Torso", shield=4, light=1))
    torso.append(bot_piece(7, "torso", "Dynamo Head", shield=4, zap=1))
    torso.append(bot_piece(6, "torso", "Crab Core", shield=4, pinch=1))
    torso.append(bot_piece(5, "torso", "Military Chassis", shield=3, light=1, blam=1))
    #torso.append(bot_piece(4, "torso", "Security Chassis", shield=3, light=1))
    #torso.append(bot_piece(3, "torso", "Big Head", shield=4))
    #torso.append(bot_piece(2, "torso", "Gun Head", shield=3, blam=1))
    #torso.append(bot_piece(1, "torso", "basic head", shield=3))

    propulsion=[]
    propulsion.append(bot_piece(11, "propulsion", "Rocket Skirt", shield=2, hover=1, burn=1))
    propulsion.append(bot_piece(10, "propulsion", "Heavy Treads", shield=2, roll=1, pow_attack=1))
    propulsion.append(bot_piece(9, "propulsion", "Gun Legs", run=2, blam=1))
    propulsion.append(bot_piece(8, "propulsion", "Hoverjack", shield=2, hover=1))
    propulsion.append(bot_piece(7, "propulsion", "Big Wheel", roll=2))
    #propulsion.append(bot_piece(6, "propulsion", "High-Speed Fan", shield=1, hover=1))
    propulsion.append(bot_piece(5, "propulsion", "Sim-Simian Feet", run=1, pinch=1))
    propulsion.append(bot_piece(4, "propulsion", "Rollerfeet", run=1, roll=1))
    #propulsion.append(bot_piece(3, "propulsion", "Tripod Legs", run=2))
    propulsion.append(bot_piece(2, "propulsion", "Heavy-Duty Legs", run=1, shield=1))
    #propulsion.append(bot_piece(1, "propulsion", "regular legs", run=1))
    
    all_pieces=[left,right,torso,propulsion]
    return all_pieces
    

def level1():
    advs=[]
    
    # guardbots
    advs.append(adv("Bulkybot", [bot_skill(pow_attack=1), bot_skill(shield=1)]))
    advs.append(adv("Doorbot", [bot_skill(pow_attack=1), bot_skill(zap=1), bot_skill(shield=1)]))
    advs.append(adv("Mookbot", [bot_skill(pow_attack=1), bot_skill(blam=1), bot_skill(shield=1)]))
    advs.append(adv("Security Drone", [bot_skill(blam=1), bot_skill(zap=1), bot_skill(shield=1)]))
    advs.append(adv("Turretbot", [bot_skill(blam=1), bot_skill(shield=1)]))
    advs.append(adv("Zippybot", [bot_skill(zap=1), bot_skill(shield=1)]))
    # easy passages
    advs.append(adv("Conveyor, Convey Thyself", [bot_skill(blam=2), bot_skill(shield=1)]))
    advs.append(adv("Crate Expectations", [bot_skill(pow_attack=2), bot_skill(shield=2)]))
    advs.append(adv("Some People Call It A Giant Slingblade", [bot_skill(run=2), bot_skill(shield=1)]))
    advs.append(adv("Tin Door. Rusted.", [bot_skill(blam=2), bot_skill(lube=1), bot_skill(shield=2)], elf_items=[0,2,0]))
    advs.append(adv("The Monster Masher!", [bot_skill(zap=2), bot_skill(shield=1)]))
    advs.append(adv("War of Gears", [bot_skill(pow_attack=2), bot_skill(hover=1), bot_skill(shield=2)], schematics=[0,1,0]))
    # reward rooms
    advs.append(adv("Inadequate Copy Room Security", [bot_skill()], schematics=[1] ))
    advs.append(adv("Locker Room", [bot_skill()], elf_items=[1] ))
    advs.append(adv("Office Space", [bot_skill(),bot_skill(pow_attack=2)], schematics=[0,1], elf_items=[1,0]))
    advs.append(adv("Paperchase", [bot_skill()], schematics=[1]))
    advs.append(adv("The Dark Closet Returns", [bot_skill(), bot_skill(light=1)], elf_items=[1,2]))
    advs.append(adv("The Dilemma", [bot_skill(),bot_skill()], schematics=[1,0], elf_items=[0,1] ))
    advs.append(adv("The Unhurt Locker", [bot_skill()], elf_items=[1] ))
    # hard passageways
    advs.append(adv("Closing Time", [bot_skill(shield=2), bot_skill(run=2, shield=1)]))
    advs.append(adv("Down In Flames", [bot_skill(blam=2, shield=1), bot_skill(shield=2)]))
    advs.append(adv("Getting Your Bearings", [bot_skill(roll=1, shield=1), bot_skill(shield=2)]))
    advs.append(adv("Gone With The Wind", [bot_skill(pow_attack=2, shield=1), bot_skill(shield=2)]))
    return advs,bot_skill()
    
    
def level2():
    advs=[]
    # Crimbot Guards
    advs.append(adv("Compugilist", [bot_skill(pow_attack=2), bot_skill(shield=2)]))
    advs.append(adv("Festively Armed", [bot_skill(lube=1), bot_skill(shield=1)]))
    advs.append(adv("Bot Your Shield", [bot_skill(blam=2), bot_skill(shield=2)]))
    advs.append(adv("Whatcha Thinkin'?", [bot_skill(zap=2), bot_skill(shield=2)]))
    advs.append(adv("I See You", [bot_skill(light=1), bot_skill(shield=1)]))
	# choice
 #   advs.append(adv("The Corporate Ladder", [bot_skill(=1), bot_skill(shield=1)])) <>
	# office reward
    advs.append(adv("This Gym Is Much Nicer", [bot_skill(pinch=1), bot_skill(pinch=1)], elf_items=[1,0], schematics=[0,1]))
    advs.append(adv("Still Life With Despair", [bot_skill(pinch=1), bot_skill(zap=2)], elf_items=[1,0], schematics=[0,1]))
    advs.append(adv("Hope You Have A Beretta", [bot_skill(pinch=1), bot_skill(blam=2)], elf_items=[0,1], schematics=[1,0]))
	# hazard
    advs.append(adv("Off The Rails", [bot_skill(roll=2, shield=2), bot_skill(shield=3.5)]))
    advs.append(adv("A Vent Horizon", [bot_skill(freeze=1, shield=2), bot_skill(shield=3.5)]))
    advs.append(adv("A Pressing Concern", [bot_skill(run=2, shield=2), bot_skill(shield=3.5)]))
    advs.append(adv("The Floor Is Like Lava", [bot_skill(hover=1,shield=2), bot_skill(shield=3.5)]))
	# hazard / reward
    advs.append(adv("Pants in High Places", [bot_skill(blam=2), bot_skill(shield=2)], schematics=[1,0]))
    advs.append(adv("Cage Match", [bot_skill(zap=2), bot_skill(shield=2)], schematics=[1,0]))
    advs.append(adv("Birdbot is the Wordbot", [bot_skill(blam=2), bot_skill(shield=2)], elf_items=[1,0]))
    advs.append(adv("Humpster Dumpster", [bot_skill(lube=1), bot_skill(shield=3)], elf_items=[1,0]))

    return advs,bot_skill(pinch=1)
    
def level3():
    advs=[]
    advs.append(adv("Unfinished Business", [bot_skill(burn=1), bot_skill(lube=1, shield=1.5), bot_skill(shield=2.5)]))
    advs.append(adv("Et Tu, Brutebot?", [bot_skill(pow_attack=3), bot_skill(pow_attack=2, shield=1.5), bot_skill(shield=2.5)]))  
    advs.append(adv("Gunception", [bot_skill(blam=3), bot_skill(blam=2, shield=1.5), bot_skill(shield=2.5)])) 
    advs.append(adv("I See What You Saw", [bot_skill(light=2), bot_skill(pinch=2, shield=1.5), bot_skill(shield=2.5)]))
    advs.append(adv("Dorkbot 4000", [bot_skill(decode=2), bot_skill(zap=2, shield=1.5), bot_skill(shield=2.5)]))
    #advs.append(adv("risk vs reward", [bot_skill(), bot_skill()]))
    
    advs.append(adv("Flameybot", [bot_skill(freeze=2, shield=1.5), bot_skill(zap=2, shield=3.5), bot_skill(shield=5.5)]))
    advs.append(adv("The Big Guns", [bot_skill(light=2, shield=1.5), bot_skill(pinch=2, shield=3.5), bot_skill(shield=5.5)]))
    advs.append(adv("Ultrasecurity Megabot", [bot_skill(decode=2, shield=1.5), bot_skill(pow_attack=3, shield=3.5), bot_skill(shield=5.5)]))

    advs.append(adv("Clear Cut Decision", [bot_skill(), bot_skill()], schematics=[1,0], elf_items=[0,2]))
    advs.append(adv("Too Few Cooks", [bot_skill(), bot_skill(freeze=1)], elf_items=[1,0], schematics=[0,1]))
    advs.append(adv("Messy, Messy", [bot_skill(), bot_skill(burn=1)], schematics=[1,0], elf_items=[0,1]))
    
    advs.append(adv("What a Grind", [bot_skill(hover=1,shield=2.5), bot_skill(lube=1,shield=3.5), bot_skill(shield=4.5)]))
    advs.append(adv("Fire! Fire! Fire!", [bot_skill(run=2,shield=2.5), bot_skill(freeze=2,shield=3.5), bot_skill(shield=4.5)]))
    advs.append(adv("Freeze!", [bot_skill(roll=2, shield=2.5), bot_skill(burn=2,shield=3.5), bot_skill(shield=4.5)]))
    
    return advs,bot_skill(decode=1)
    
    
all_pieces = get_all_pieces()
#advs,mandatory=level1()
#advs,mandatory=level2()
advs,mandatory=level3()
best_gear = try_permutations(all_pieces,advs,mandatory)
test_gear_on_advs(best_gear[0]+best_gear[1]+best_gear[2]+best_gear[3],advs)
    