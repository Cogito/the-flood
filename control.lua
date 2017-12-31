--- Flood an area
-- Finds all tiles within a BoundingBox that are meant to be underwater, and makes them so
local function flood_area(surface, area)
    local flood_location = global.flood_location
    local water_tiles = {}
    local lt = area.left_top
    local rb = area.right_bottom

    for x = lt.x, rb.x do
        for y = lt.y, rb.y do
            if x <= flood_location then
                table.insert(water_tiles, {name = "water", position = {x, y}})
            end
        end
    end

    surface.set_tiles(water_tiles)
end


local function check_spawns(surface)
    local flood_location = global.flood_location

    for _, force in pairs(game.forces) do
        local spawn_position = force.get_spawn_position(surface)
        if spawn_position.x <= flood_location + 10 then
            force.set_spawn_position({x = flood_location + 10, y = spawn_position.y}, surface)
        end
    end
end


--- Flood the map!
-- Extend the flooded portion of the map by one step
local function flood(surface)
    global.flood_location = global.flood_location + 1
    local flood_location = global.flood_location

    for chunk in surface.get_chunks() do
        if chunk.x <= flood_location / 32 and chunk.x >= flood_location / 32 - 1 then
            local area = {
                left_top = {x = chunk.x * 32, y = chunk.y * 32},
                right_bottom = {x = chunk.x * 32 + 32, y = chunk.y * 32 + 32}
            }
            flood_area(surface, area)
        end
    end

    check_spawns(surface)
end


--- Flood newly generated chunks
-- When a new chunk is generated, check each of its tiles, and flood them if needed
local function flood_new_chunk(event)
    flood_area(event.surface, event.area)
end


--- on_tick event handler
-- Used to flood the map on a regular interval
local function on_tick()
    local flood_speed = global.flood_speed
    if game.tick % flood_speed == 0 then
        flood(game.surfaces.nauvis)
    end
end


local function init()
    global.flood_location = settings.global["the-flood-start-location"].value
    global.flood_speed = settings.global["the-flood-speed"].value -- update the flood every this many ticks
end


script.on_event(defines.events.on_chunk_generated, flood_new_chunk)
script.on_event(defines.events.on_tick, on_tick)
script.on_init(init)
