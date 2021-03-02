Config = {}

Config.Round = {
    ["DefaultTime"] = (60 * 7) + 34,
}

Config.Moods = {
    {
        ['Hour'] = 12,
        ['Look'] = 'int_Lost_small',
        ['Intensity'] = 0.9,
        ['Weather'] = 'FOGGY'
    },
    {
        ['Hour'] = 0,
        ['Look'] = 'lab_none_exit_OVR',
        ['Intensity'] = 0.95,
        ['Weather'] = 'FOGGY'
    },
    {
        ['Hour'] = 12,
        ['Look'] = 'mp_bkr_ware01',
        ['Intensity'] = 0.80,
        ['Weather'] = 'EXTRASUNNY'
    }
}

Config.Models = {
    {"joel", "Joel"},
    {"ElliePatrol", "Ellie"},
    {"s_m_y_dealer_01", "Hunter"},
    {"csb_mweather", "Firefly"},
}

Config.Ranks = {
    {
        ['MinScore'] = 0, ['Unlocks'] = {{'WEAPON_MACHETE'}, {'WEAPON_SMG', 64, 'COMPONENT_AT_PI_SUPP'}}
    },
    {
        ['MinScore'] = 1, ['Unlocks'] = {{'WEAPON_PISTOL', 1}}
    },
    {
        ['MinScore'] = 2, ['Unlocks'] = {{'WEAPON_PISTOL', 4}, {'WEAPON_MOLOTOV', 2}}
    },
    {
        ['MinScore'] = 4, ['Unlocks'] = {{'WEAPON_PISTOL', 8}, {'WEAPON_REVOLVER', 4}}
    },
    {
        ['MinScore'] = 8, ['Unlocks'] = {{'WEAPON_PISTOL', 14}, {'WEAPON_REVOLVER', 12}, {'WEAPON_PUMPSHOTGUN', 6}}
    },
    {
        ['MinScore'] = 16, ['Unlocks'] = {{'WEAPON_PUMPSHOTGUN', 12}, {'WEAPON_PIPEBOMB', 2}}
    },
    {
        ['MinScore'] = 32, ['Unlocks'] = {{'WEAPON_SMG', 64, 'COMPONENT_AT_SR_SUPP'}}
    }
}