function main()
    local numTracks = reaper.CountSelectedTracks(0)
    if numTracks < 2 then return end -- Need at least two tracks selected

    local destTrack = reaper.GetSelectedTrack(0, numTracks - 1) -- Last selected track is the destination track

    -- Clear existing receives on the destination track
    for i = reaper.GetTrackNumSends(destTrack, -1) - 1, 0, -1 do
        reaper.RemoveTrackSend(destTrack, -1, i)
    end

    -- Create a receive track on the destination track for each source track
    for i = 0, numTracks - 1 do
        local srcTrack = reaper.GetSelectedTrack(0, i)

        -- Create receive track using TrackFX_AddByName with empty plugin name
        local receiveIdx = reaper.TrackFX_AddByName(destTrack, "", false, -1)
        local srcIdx = 0 -- Index of the first output
        local destIdx = reaper.GetTrackNumSends(destTrack, -1) - 1 -- Subtract 1 to account for 0-based indexing

        -- Set receive input to ascending numbers from 1 to X with source channel set to 1
        reaper.SetTrackSendInfo_Value(destTrack, -1, destIdx, "I_SRCCHAN", (0 | 1024))
        reaper.SetTrackSendInfo_Value(destTrack, -1, destIdx, "I_DSTCHAN", i + (0 | 1024)-1)
        reaper.SetTrackSendInfo_Value(destTrack, -1, destIdx, "I_MIDI_SRCCHAN", 1)

        -- Set send from source track to the receive track as mono source (source 1)
        reaper.CreateTrackSend(srcTrack, destTrack)
        reaper.SetTrackSendInfo_Value(srcTrack, 0, receiveIdx, "I_SENDMODE", 3) -- Set send mode to "Audio > mono source > 1"
        reaper.SetTrackSendInfo_Value(srcTrack, 0, receiveIdx, "I_SRCCHAN", 0x01000000) -- Set send input to "Audio > mono source > 1"
    end
end

reaper.Undo_BeginBlock() -- Begin undo block
main() -- Call the main function
reaper.Undo_EndBlock("Connect Tracks Sequentially", -1) -- End undo block with a custom name

