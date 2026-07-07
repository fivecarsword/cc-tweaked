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

local function initTitle()
    mon.setTextScale(1)

    width, height = mon.getSize()
end

local function titleLogic()
    if (relay.getInput("up")) then
        return false
    end

    return true
end

local function drawTitle()
    mon.setBackgroundColor(colors.fromBlit("7"))
    mon.setTextColor(colors.fromBlit("4"))

    mon.setCursorPos(1, 2)
    mon.write("                    _     _ ")
    mon.setCursorPos(1, 2)
    mon.write("     /\\            (_)   | |")
    mon.setCursorPos(1, 2)
    mon.write("    /  \\__   _____  _  __| |")
    mon.setCursorPos(1, 2)
    mon.write("   / /\\ \\ \\ / / _ \\| |/ _` |")
    mon.setCursorPos(1, 2)
    mon.write("  / ____ \\ V / (_) | | (_| |")
    mon.setCursorPos(1, 2)
    mon.write(" /_/    \\_\\_/ \\___/|_|\\__,_|")
end

local function titleLoop()
    initTitle()
    frame = 0

    while (true) do

        if (not titleLogic()) then
            return
        end

        drawTitle()

        frame = frame + 1
        os.sleep(0.05)
    end
end

local function initMain()
    mon.setTextScale(3)

    width, height = mon.getSize()

    x = math.floor(width / 2)
    y = height - 1

    o_x = math.random(1, width)
    o_y = 0
end

local function mainLogic()
    if (relay.getInput("left")) then
        x = math.max(1, x - 1)
    end
    
    if (relay.getInput("right")) then
        x = math.min(width, x + 1)
    end

    o_y = o_y + 1

    if (x == o_x and y == o_y) then
        speak.playSound("entity.player.hurt")
        return false
    end

    if (o_y >= height) then
        o_y = 0
        o_x = math.random(1, width)
    end

    return true
end

local function drawMain()
    mon.setBackgroundColor(colors.fromBlit("3"))
    mon.clear()

    mon.setCursorPos(x, y)
    mon.setTextColor(colors.fromBlit("b"))
    mon.write("P")

    mon.setCursorPos(o_x, o_y)
    mon.setTextColor(colors.fromBlit("e"))
    mon.write("@")

    mon.setCursorPos(1, height)
    mon.setBackgroundColor(colors.fromBlit("c"))
    mon.write(string.rep(" ", width))
end

local function mainLoop()
    initMain()
    frame = 0

    while (true) do

        if (frame % 2 == 0) then
            if (not mainLogic()) then
                return
            end
        end

        drawMain()

        music()

        frame = frame + 1
        os.sleep(0.05)
    end
end

mon = peripheral.find("monitor")
relay = peripheral.find("redstone_relay")
speak = peripheral.find("speaker")

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
    titleLoop()
    mainLoop()
end

mon.clear()