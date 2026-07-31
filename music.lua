local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")

if not speaker then
    print("Error: Speaker peripheral not found.")
    print("Please attach a speaker to the computer.")
    return
end

local wsURL = "ws://192.168.35.120:51155"
print("Connecting to server (" .. wsURL .. ")...")

local ws, err = http.websocket(wsURL)
if not ws then
    print("Failed to connect: " .. tostring(err))
    return
end

print("Connected successfully!")

-- 1. 음원 목록 요청
ws.send(textutils.serializeJSON({action = "list"}))

local msg, isBinary = ws.receive()
if not msg then
    print("Connection closed by server.")
    return
end

local response = textutils.unserializeJSON(msg)
if not response or response.action ~= "list" then
    print("Invalid response from server.")
    ws.close()
    return
end

local songs = response.songs
if #songs == 0 then
    print("No songs available on the server.")
    print("Please add .dfpwm files to the 'songs' folder.")
    ws.close()
    return
end

-- 2. 음원 목록 출력 및 선택
print("\n--- Available Songs ---")
for i, song in ipairs(songs) do
    print(i .. ". " .. song)
end
print("-----------------------")

io.write("Select a song to play (enter number): ")
local choice_str = io.read()
local choice = tonumber(choice_str)

if not choice or not songs[choice] then
    print("Invalid selection.")
    ws.close()
    return
end

local selected_song = songs[choice]
print("\nPlaying: " .. selected_song)

-- 3. 청크 단위로 스트리밍 및 재생
local decoder = dfpwm.make_decoder()
local offset = 0
local chunkSize = 16 * 1024 -- 16KB

while true do
    -- 다음 청크 요청
    ws.send(textutils.serializeJSON({
        action = "chunk",
        song = selected_song,
        offset = offset,
        size = chunkSize
    }))
    
    local chunk, isBin = ws.receive()
    
    if not chunk then
        print("Connection closed during playback.")
        break
    end
    
    if not isBin then
        -- 텍스트 메시지가 온 경우 에러일 가능성이 높음
        local errResp = textutils.unserializeJSON(chunk)
        if errResp and errResp.error then
            print("Error from server: " .. errResp.error)
        end
        break
    end
    
    if #chunk == 0 then
        -- 빈 바이너리가 오면 파일의 끝에 도달한 것
        print("Playback finished.")
        break
    end
    
    -- 청크를 디코딩하고 재생
    local buffer = decoder(chunk)
    while not speaker.playAudio(buffer) do
        -- 버퍼가 꽉 찼다면 공간이 생길 때까지 대기
        os.pullEvent("speaker_audio_empty")
    end
    
    offset = offset + #chunk
end

ws.close()
print("Disconnected from server.")
