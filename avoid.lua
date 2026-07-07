// wget https://raw.githubusercontent.com/fivecarsword/cc-tweaked/master/avoid.lua

local function gameLogic()
    if (relay.getInput("left")) then
        x = math.max(1, x - 1)
    end
    
    if (relay.getInput("right")) then
        x = math.min(width, x + 1)
    end

    o_y = o_y + 1

    if (x == o_x and y == o_y) then
        return false
    end

    if (o_y > height) then
        o_y = 0
        o_x = math.random(1, width)
    end

    return true
end

local function draw()
    mon.clear()

    mon.setCursorPos(x, y)
    mon.write("P")

    mon.setCursorPos(o_x, o_y)
    mon.write("@")
end

local function music()
    if (beat[beatIdx][1] <= beatFrame) then
        beatIdx = (beatIdx + 1) #beat
        beatFrame = 0
    end

    if (beatFrame == 0) then
        speak.playNote(beat[beatIdx][0], 1, 12)
    end

    beatFrame = beatFrame + 1
end

mon = peripheral.find("monitor")
relay = peripheral.find("redstone_relay")
speak = peripheral.find("speaker")

mon.setTextSale(3)

width, height = mon.getSize()

x = math.floor(width / 2)
y = height

o_x = math.random(1, width)
o_y = 0

melody = {

}
beat = {
    {"basedrum", 5}
}

melodyIdx = 0
melodyFrame = 0

beatIdx = 0
beatFrame = 0

frame = 0

while (true) do
    if (frame % 2 == 0) then
        if (not gameLogic(frame)) then
            break
        end
    end

    draw()

    music()

    frame = frame + 1
    os.sleep(0.05)
end

mon.clear()