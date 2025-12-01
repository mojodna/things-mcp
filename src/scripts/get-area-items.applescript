on run argv
    if (count of argv) < 1 then
        error "Area ID required"
    end if
    
    set areaId to item 1 of argv
    set maxResults to -1
    
    -- Check for optional max results parameter
    if (count of argv) > 1 then
        try
            set maxResults to (item 2 of argv) as integer
        end try
    end if
    
    tell application "Things3"
        set output to ""
        set itemCount to 0

        -- Use direct area lookup - much faster than searching
        try
            set targetArea to area id areaId
        on error errMsg
            error "Area not found: " & areaId & " (" & errMsg & ")"
        end try

        -- Get todos directly from area - much faster than iterating all todos
        repeat with toDo in to dos of targetArea
            -- Check max results limit
            if maxResults > 0 and itemCount ≥ maxResults then
                exit repeat
            end if

            try
                set todoId to id of toDo
                set todoName to name of toDo

                -- Area is already known
                set todoArea to ""

                -- Get tag names
                set todoTags to ""
                try
                    set todoTags to tag names of toDo
                    if todoTags is missing value then set todoTags to ""
                on error
                    set todoTags to ""
                end try

                -- Build output line
                set output to output & todoId & "|" & todoName & "|" & todoArea & "|" & todoTags & linefeed
                set itemCount to itemCount + 1

            on error errMsg
                log "Error processing todo: " & errMsg
            end try
        end repeat
        
        -- Also get projects in area
        -- Note: Things 3 doesn't support "projects of area", so we must iterate all projects
        repeat with proj in projects
            -- Check if project belongs to this area
            try
                if area of proj is not missing value and area of proj is equal to targetArea then
                    -- Check max results limit
                    if maxResults > 0 and itemCount ≥ maxResults then
                        exit repeat
                    end if

                    -- Only include open projects
                    if status of proj is open then
                        set projId to id of proj
                        set projName to name of proj

                        -- Area is already known
                        set projArea to ""

                        -- Get tag names
                        set projTags to ""
                        try
                            set projTags to tag names of proj
                            if projTags is missing value then set projTags to ""
                        on error
                            set projTags to ""
                        end try

                        -- Build output line
                        set output to output & projId & "|" & projName & "|" & projArea & "|" & projTags & linefeed
                        set itemCount to itemCount + 1
                    end if
                end if

            on error errMsg
                log "Error processing project: " & errMsg
            end try
        end repeat
        
        return output
    end tell
end run