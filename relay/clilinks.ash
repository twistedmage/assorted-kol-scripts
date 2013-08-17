// CLI Links by Zarqon
string cmd = form_fields()["cli"];
switch (cmd) {
   case "": write("Nothing successfully accomplished!"); exit;
   default: write(cli_execute(cmd) ? (cmd == "help" ? "A complete list of CLI commands has been printed in the CLI." :
      "Command '"+cmd+"' executed.") : "Error executing '"+cmd+"'.");
}