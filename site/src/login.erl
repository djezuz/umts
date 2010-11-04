-module (login).
-compile(export_all).
-include_lib("nitrogen/include/wf.hrl").

-include("mtg_db.hrl").

main() -> #template { file="./templates/bare.html" }.

title() -> "Login to ///MTG".

body() ->
    #container_12{body = [
			  #grid_8{alpha=true, 
				  prefix=2, 
				  suffix=2, 
				  omega=true, 
				  body=inner_body(),
				  style = "text-align: center;"
				 }
			 ]}.

inner_body() ->
    [#flash{},
     "Username:",
     #textbox{id = username},
     "Password:",
     #password{id = password, postback = login},
     #br{},
     #button{text = "Login", postback = login},
     #button{text = "Register", postback = register},
     #lightbox{id = lb,  
	       body = [#panel{id = confirmbox,
			      body = ["Confirm password:",
				      #password{id = password2, postback = confirm},
				      #button{text = "Confirm", postback = confirm},
				      #button{text = "Cancel", postback = cancel_confirm}]}],
	       style = "display: none;"}
    ].
	
event(login) ->
    Username = wf:q(username),
    Password = wf:q(password),
    case mtg_db:login(Username, Password) of
	not_found ->
	    wf:flash("Incorrect username or password");
	Id ->
	    wf:user(Id),
	    wf:redirect("/")
    end;
event(register) ->
    Username = wf:q(username),
    Password = wf:q(password),
    case length(Username) == 0
	orelse length(Password) == 0 of 
	true ->
	    wf:flash("Please enter a username and password to register");
	false ->
	    wf:wire(lb, #show{})
    end;
event(confirm) ->
    Username = wf:q(username),
    Password = wf:q(password),
    Password2 = wf:q(password2),
    wf:wire(lb, #hide{}),
    case Password == Password2 of
	true ->
	    case mtg_db:insert_user(Username, Password) of
		{ok, NewID} ->
		    wf:user(NewID),
		    wf:redirect("/");
		{fault, exists} ->
		    wf:flash("Username already exists")
	    end;
	false ->
	    wf:flash("Password doesn't match")
    end;
event(cancel_confirm) ->
    wf:wire(lb, #hide{}).
