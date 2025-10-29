select(2, ...) 'rosterfilter.tabs.friends'

local rosterfilter = require 'rosterfilter'

local tab = rosterfilter.tab 'Friends'


local friends_cache = {};
local friendlist_update_listener;


function rosterfilter.handle.LOAD()

end


function tab.OPEN()
    friendlist_update_listener = rosterfilter.event_listener("FRIENDLIST_UPDATE", function() refresh = true; end)
    local friends = GetNumFriends();
    if friends >= 50 then
        add_button:Disable()
    end
    frame:Show()
    refresh = true
end


function tab.CLOSE()
    frame:Hide()
end


function update_listing()
    rosterfilter.wipe(friends_cache)

    local friends = GetNumFriends();

    local rows = {};

    for i = 1, friends do
        -- In Vanilla WoW: name, level, class, area, connected, status, notes = GetFriendInfo(index)
        local name, level, class, area, connected, status_flag, notes = GetFriendInfo(i);
        
        local status = "";
        if status_flag == "<DND>" then 
            status = "<DND>" 
        elseif status_flag == "<AFK>" then 
            status = "<AFK>" 
        end

        local friend = {
            ['name'] = name,
            ['level'] = level,
            ['class'] = class,
            ['zone'] = area,
            ['online'] = connected,
            ['status'] = status,
            ['notes'] = notes or ""
        }
        tinsert(friends_cache, friend)

        local alpha = 1.0;
        if not friend.online then
            alpha = 0.4;
        end

        tinsert(rows, {
            ['cols'] = {
                {['name'] = 'class', ['value'] = '', ['sort'] = friend.class},
                {['name'] = 'name', ['value'] = friend.name .. ' ' .. friend.status, ['sort'] = friend.name},
                {['name'] = 'level', ['value'] = friend.level, ['sort'] = tonumber(friend.level)},
                {['name'] = 'zone', ['value'] = friend.zone, ['sort'] = friend.zone},
                {['name'] = 'notes', ['value'] = friend.notes, ['sort'] = friend.notes},
                {['name'] = 'online', ['value'] = friend.online, ['sort'] = friend.online}
            },
            ['record'] = friend,
            ['alpha'] = alpha
        })

    end

    player_listing.sortColumn = 6
    player_listing.sortInvert = true
    player_listing:SetData(rows)
end


function on_update()
    if refresh then
        update_listing()
        refresh = false
    end
end


function on_hide()
    rosterfilter.kill_listener(friendlist_update_listener)
end
