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

    if (o_y >= height) then
        o_y = 0
        o_x = math.random(1, width)
    end

    return true
end

local function draw()
    mon.setBackgroundColor(colors.fromBlit("3"))
    mon.clear()

    mon.setCursorPos(1, height)
    mon.setBackgroundColor(colors.fromBlit("c"))
    mon.write(string.rep(" ", width))

    mon.setCursorPos(x, y)
    mon.setTextColor(colors.fromBlit("b"))
    mon.write("P")

    mon.setCursorPos(o_x, o_y)
    mon.setTextColor(colors.fromBlit("e"))
    mon.write("@")
end

local function music()
    if (melody[melodyIdx + 1][3] <= melodyFrame) then
        melodyIdx = (melodyIdx + 1) % #melody
        melodyFrame = 0
    end

    if (melodyFrame == 0 and melody[melodyIdx + 1][1] ~= "") then
        speak.playNote(melody[melodyIdx + 1][1], 1, melody[melodyIdx + 1][2])
    end

    melodyFrame = melodyFrame + 1

    if (beat[beatIdx + 1][3] <= beatFrame) then
        beatIdx = (beatIdx + 1) % #beat
        beatFrame = 0
    end

    if (beatFrame == 0 and beat[beatIdx + 1][1] ~= "") then
        speak.playNote(beat[beatIdx + 1][1], 1, beat[beatIdx + 1][2])
    end

    beatFrame = beatFrame + 1
end

mon = peripheral.find("monitor")
relay = peripheral.find("redstone_relay")
speak = peripheral.find("speaker")

mon.setTextScale(3)

width, height = mon.getSize()

x = math.floor(width / 2)
y = height - 1

o_x = math.random(1, width)
o_y = 0

melody = {
    {"bit", 6, 4},
    {"bit", 10, 4},
    {"bit", 13, 4},
    {"bit", 18, 8},
    {"", 0, 4},
    {"bit", 13, 4},
    {"bit", 18, 4},
    {"bit", 11, 4},
    {"bit", 15, 4},
    {"bit", 18, 4},
    {"bit", 11, 4},
    {"", 0, 4},
    {"bit", 18, 4},
    {"bit", 15, 8},
}
beat = {
    {"basedrum", 12, 4},
    {"hat", 12, 4},
}

melodyIdx = 0
melodyFrame = 0

beatIdx = 0
beatFrame = 0

frame = 0

while (true) do
    if (frame % 2 == 0) then
        if (not gameLogic()) then
            break
        end
    end

    draw()

    music()

    frame = frame + 1
    os.sleep(0.05)
end

mon.clear()