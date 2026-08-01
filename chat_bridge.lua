local chatBox = peripheral.find("chatBox")

if not chatBox then
    print("Error: Chat Box peripheral not found.")
    print("Please place a Chat Box next to the computer.")
    return
end

local wsURL = "ws://192.168.35.120:51155"
print("Connecting to Discord Bridge Server (" .. wsURL .. ")...")

local ws, err = http.websocket(wsURL)
if not ws then
    print("Failed to connect: " .. tostring(err))
    return
end

print("Connected to Discord Bridge successfully!")

-- 1. 디스코드에서 오는 메시지를 받아서 마인크래프트에 뿌리기
local function receiveFromDiscord()
    while true do
        local msg = ws.receive()
        if not msg then
            print("Connection closed by server.")
            break
        end
        
        local data = textutils.unserializeJSON(msg)
        if data and data.type == "discord" then
            -- Chat Box를 이용해 마인크래프트 채팅창에 표시
            -- sendMessage(메시지, 접두사(유저이름))
            local success, err = pcall(function()
                chatBox.sendMessage(data.message, data.user)
            end)
            if not success then
                print("Failed to send message to Chat Box: " .. tostring(err))
            end
        end
    end
end

-- 2. 마인크래프트에서 친 채팅을 잡아서 웹소켓으로(디스코드로) 보내기
local function sendToDiscord()
    while true do
        -- Advanced Peripherals의 'chat' 이벤트 감지
        local event, username, message, uuid, isHidden = os.pullEvent("chat")
        
        -- JSON으로 변환하여 웹소켓 서버로 전송
        ws.send(textutils.serializeJSON({
            type = "chat",
            user = username,
            message = message
        }))
    end
end

-- 두 개의 루프(함수)를 동시에 실행
parallel.waitForAny(receiveFromDiscord, sendToDiscord)

if ws then
    ws.close()
end
print("Discord Bridge disconnected.")
