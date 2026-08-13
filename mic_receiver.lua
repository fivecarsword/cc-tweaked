local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")

if not speaker then
    print("Error: Speaker peripheral not found.")
    print("Please attach a speaker to the computer.")
    return
end

-- Python 서버와 동일한 IP, 포트를 사용합니다.
local wsURL = "ws://192.168.35.120:51155"
print("Connecting to microphone server (" .. wsURL .. ")...")

local ws, err = http.websocket(wsURL)
if not ws then  
    print("Failed to connect: " .. tostring(err))
    return
end

print("Connected successfully! Listening to microphone...")
print("Press Ctrl+T to terminate.")

local decoder = dfpwm.make_decoder()

while true do
    local chunk, isBin = ws.receive()
    
    if not chunk then
        print("Connection closed by server.")
        break
    end
    
    if isBin and #chunk > 0 then
        -- 수신된 DFPWM 데이터를 디코딩
        local buffer = decoder(chunk)
        
        -- 버퍼의 평균 소리 크기(절댓값)를 계산하여 볼륨 바 표시
        local sum = 0
        for i = 1, #buffer do
            sum = sum + math.abs(buffer[i])
        end
        local avg = #buffer > 0 and (sum / #buffer) or 0
        
        -- 볼륨 바 그리기 (최대 30칸)
        local barLen = math.floor(avg / 3) 
        if barLen > 30 then barLen = 30 end
        local x, y = term.getCursorPos()
        term.setCursorPos(1, y)
        term.clearLine()
        term.write("[Mic In] |" .. string.rep("#", barLen) .. string.rep(" ", 30 - barLen) .. "|")
        
        -- 스피커에 버퍼 공간이 생길 때까지 대기하며 재생
        while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end

if ws then
    ws.close()
end
print("Disconnected.")
