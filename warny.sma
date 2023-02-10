#include <amxmodx>
#include <nvault>

#define prefix "^4[Warny]^1"

new iWarns[32], iTarget;

new gVault, g_iIloscSlotow;

new const szPowody[][] = {
	"Nie ogarniasz",
	"Nie znasz regulaminu",
	"Obraza graczy"
};

public plugin_init() {
	register_plugin("System Warnow", "1.0", "Bodcio");
	
	register_clcmd("say /warny", "Cmd_Warn_glowne");
	
	nvault_open("Warn_System");	
	
	g_iIloscSlotow = get_maxplayers();
}

public client_putinserver(id) {
	iWarns[id] = 0;
	
	new value[32];
	nvault_get(gVault, fmt("%n", id), value, charsmax(value));
	replace_all(value, charsmax(value), "#", " ");
	new warns[32];
	parse(value, warns, charsmax(warns));	
	iWarns[id] = str_to_num(warns);
	nvault_close(gVault);
}

public Cmd_Warn_glowne(id) 
{
	new menu = menu_create("\wMenu \rwarnow:", "warn_handler_glowne");
	new cb = menu_makecallback("Menu_Callback");
	
	menu_additem(menu, "Daj \rwarna", "0", 1, cb);	
	menu_additem(menu, "Usun \rwarny", "1", 2, cb);
		
	menu_setprop(menu, MPROP_BACKNAME, "Wstecz");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Zamknij");	
	menu_display(id, menu);
}

public Menu_Callback(id, menu, item)
{
	static num[10], acces, callback;
	menu_item_getinfo(menu, item, acces, num, 9, _, _, callback);
 
	switch(acces)
	{
		case 1:{
			if(!(get_user_flags(id) & ADMIN_KICK)) {
				return ITEM_DISABLED;
			}
		}
		case 2:{
			if(!(get_user_flags(id) & ADMIN_IMMUNITY)) {
				return ITEM_DISABLED;
			}
		}	
	}
	return ITEM_ENABLED;
}

public warn_handler_glowne(id, menu, item) {
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	switch(item) {
		case 0: Cmd_Warn(id);
		case 1: Cmd_ResetWarns(id);		
	}
	return PLUGIN_CONTINUE;
}

public Cmd_Warn(id) 
{
	new menu = menu_create("\wWybierz \ygracza:", "handler_warn"), szID[4];
	
	for(new i = 1; i <= g_iIloscSlotow; i++)
	{
		if(!is_user_connected(i) || is_user_hltv(i)) continue;
		
		num_to_str(i, szID, charsmax(szID));
		menu_additem(menu, fmt("%n \r%i", i, iWarns[i]), szID);
	}	
	
	menu_setprop(menu, MPROP_BACKNAME, "Wstecz");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Zamknij");		
	menu_display(id, menu);
}

public handler_warn(id, menu, item) {
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new iCb, szID[4];
	menu_item_getinfo(menu, item, _, szID, charsmax(szID), _, _, iCb);
	iTarget = str_to_num(szID);	
	
	menu_destroy(menu);
	Cmd_Powod(id);
	return PLUGIN_HANDLED;
}

public Cmd_Powod(id) 
{
	new menu = menu_create("\wPowod \rwarna:", "warn_handler")
	
	for(new i = 0; i < sizeof szPowody; i++)
		menu_additem(menu, fmt("%s", szPowody[i]));	
		
	menu_setprop(menu, MPROP_BACKNAME, "Wstecz");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Zamknij");	
	menu_display(id, menu);
}

public warn_handler(id, menu, item) {
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new iCb, szID[4];
	menu_item_getinfo(menu, item, _, szID, charsmax(szID), _,  _, iCb);	
	
	iWarns[iTarget] += 1;
    
	client_print_color(0, 0, "%s ^4%n^1 dal warna dla^4 %n^3 [%i]^1.Powod:^4 %s", prefix, id, iTarget, iWarns[iTarget], szPowody[item]);
	nvault_set(gVault, fmt("%n", id), fmt("%i", iWarns[iTarget]));
	nvault_close(gVault);
	
	menu_destroy(menu);
	return PLUGIN_HANDLED	
}

public Cmd_ResetWarns(id) {
	new menu = menu_create("\wUsun \rwarny:", "Cmd_HandleReset")
	
	menu_additem(menu, "Wybierz gracza");
	
	menu_setprop(menu, MPROP_BACKNAME, "Wstecz");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Zamknij");		
	menu_display(id, menu);
}

public Cmd_HandleReset(id, menu, item) {
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	Cmd_Reset(id);
	return PLUGIN_CONTINUE;
}

public Cmd_Reset(id) {
	new menu = menu_create("\wWybierz \ygracza:", "Cmd_ResetPlayerHandler"), szID[4];
	
	for(new i = 1; i <= g_iIloscSlotow; i++)
	{
		if(!is_user_connected(i) || is_user_hltv(i) || iWarns[i] <= 0) continue;
		
		num_to_str(i, szID, charsmax(szID));
		menu_additem(menu, fmt("%n \r%i", i, iWarns[i]), szID);
	}	
	
	menu_setprop(menu, MPROP_BACKNAME, "Wstecz");
	menu_setprop(menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(menu, MPROP_EXITNAME, "Zamknij");		
	menu_display(id, menu);
}

public Cmd_ResetPlayerHandler(id, menu, item) {
	if(item == MENU_EXIT) {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new iCb, szID[4];
	menu_item_getinfo(menu, item, _, szID, charsmax(szID), _,  _, iCb);	
	iTarget = str_to_num(szID);	
	
	iWarns[iTarget] = 0;
	
	client_print_color(iTarget, iTarget, "%s ^3Wlasciciel^1 usunal twoje^4 warny!", prefix);
	client_print_color(0, 0, "%s ^3Wlasciciel^1 usunal wszystkie^3 warny^1 dla^4 %n^3 !", prefix, iTarget);
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}