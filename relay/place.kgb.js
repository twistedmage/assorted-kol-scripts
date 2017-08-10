
var __relay_url = "place.kgb.ash";


function parseDisableEnableResponse(response_string)
{
	location.reload();
}


function deleteElement(parent_element, element)
{
	try
	{
		parent_element.removeChild(element);
	}
	catch (exception)
	{
		return;
	}
	
}

var __popups_visible = 0;

function fadeOutPopup(parent_element, popup_element)
{
	if (__popups_visible == 1)
	{
		var popup_container = document.getElementById("briefcase_notification_div");
		popup_container.style.transition = "opacity 1.0s linear";
		popup_container.style.opacity = 0.0;
	}
	popup_element.style.opacity = 0.0;
	setTimeout(function() {deleteElement(parent_element, popup_element); __popups_visible -= 1;}, 1000);
	
}

function parseRelayResponse(response_string, popup_element)
{
	var response;
	try
	{
		response = JSON.parse(response_string);
	}
	catch (exception)
	{
		return;
	}
	var core_html = response["core HTML"];
	var popup_result = response["popup result"];
	
	if (popup_result != undefined && popup_result != "")
	{
		var popup_container = document.getElementById("briefcase_notification_div");
		
		//Move the rest of them up:
		/*var other_elements = popup_container.getElementsByClassName("briefcase_popup");
		
		if (other_elements != undefined)
		{
			for (var i = 0; i < other_elements.length; i++)
			{
				var element = other_elements[i];
				var current_value = 0;
				if (element.style.marginTop != "")
					current_value = element.style.marginTop.replace("px", "");
				var new_value = current_value - 30;
				element.style.marginTop = new_value + "px";
			}
		}*/
		
		//Update
		popup_element.innerHTML = popup_result;
		setTimeout(function() {fadeOutPopup(popup_container, popup_element)}, 7000);
	}
	
	//document.body.innerHTML = body_html;
	document.getElementById("briefcase_main_holder_div").innerHTML = core_html;
}

function executeBriefcaseCommand(command)
{
	
	var popup_container = document.getElementById("briefcase_notification_div");
	popup_container.style.transition = "";
	popup_container.style.opacity = 1.0;
	var new_popup = document.createElement("div");
	//new_popup.style = "";
	new_popup.setAttribute("class", "briefcase_popup");
	__popups_visible += 1;
	//new_popup.innerHTML = "Running " + command + "...";
	new_popup.innerHTML = "Running..."; //in the nineties
	popup_container.appendChild(new_popup);
	
	if (false)
	{
		//Halfway-implemented experiment, seems distracting:
		new_popup.style.marginRight = "-" + new_popup.clientWidth + "px";
		new_popup.offsetHeight; //force movement
		new_popup.style.transition = "margin-right 0.1s ease-out";
		new_popup.style.marginRight = "0px";
	}	
	
	var form_data = "relay_request=true&type=execute_command&command=" + command;
	var request = new XMLHttpRequest();
	request.onreadystatechange = function() { if (request.readyState == 4) { if (request.status == 200) { parseRelayResponse(request.responseText, new_popup); } } }
	request.open("POST", __relay_url);
	request.send(form_data);
}

function disableGUI()
{
	var form_data = "relay_request=true&type=disable_gui";
	var request = new XMLHttpRequest();
	request.onreadystatechange = function() { if (request.readyState == 4) { if (request.status == 200) { parseDisableEnableResponse(request.responseText); } } }
	request.open("POST", __relay_url);
	request.send(form_data);
}