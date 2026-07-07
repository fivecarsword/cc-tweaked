local function gameLogic()
    if (relay.getInput("left")) then
        x = math.max(1, x - 1)
    end
    
    if (relay.getInput("right")) then
        x = math.min(width, x + 1)
    end

    o_y = o_y + 1

    if (x == o_x and y == o_y) then
        break
    end

    if (o_y > height) then
        o_y = 0
        o_x = math.random(1, width)
    end
end

local function draw()
    mon.clear()

    mon.setCursorPos(x, y)
    mon.write("P")

    mon.setCursorPos(o_x, o_y)
    mon.write("@")
end

local function music()

end

mon = peripheral.find("monitor")
relay = peripheral.find("redstone_relay")

mon.setTextSale(3)

width, height = mon.getSize()

x = math.floor(width / 2)
y = height

o_x = math.random(1, width)
o_y = 0

while (true) do
    gameLogic()
    draw()

    os.sleep(0.1)
end
