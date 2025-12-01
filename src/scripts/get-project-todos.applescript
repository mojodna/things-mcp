on run argv
    if (count of argv) < 1 then
        error "Project ID required"
    end if
    
    set projectId to item 1 of argv
    set maxResults to -1
    
    -- Check for optional max results parameter
    if (count of argv) > 1 then
        try
            set maxResults to (item 2 of argv) as integer
        end try
    end if
    
    tell application "Things3"
        set output to ""
        set todoCount to 0

        -- Use direct project lookup - much faster than searching
        try
            set targetProject to project id projectId
        on error errMsg
            error "Project not found: " & projectId & " (" & errMsg & ")"
        end try
        
        -- Get todos from project
        repeat with toDo in to dos of targetProject
            -- Check max results limit
            if maxResults > 0 and todoCount ≥ maxResults then
                exit repeat
            end if
            
            try
                set todoId to id of toDo
                set todoName to name of toDo
                
                -- Project todos don't have separate area
                set todoArea to ""
                
                -- Get tag names (using built-in property)
                set todoTags to ""
                try
                    set todoTags to tag names of toDo
                    if todoTags is missing value then set todoTags to ""
                on error
                    set todoTags to ""
                end try
                
                -- Build output line
                set output to output & todoId & "|" & todoName & "|" & todoArea & "|" & todoTags & linefeed
                set todoCount to todoCount + 1
                
            on error errMsg
                log "Error processing todo: " & errMsg
            end try
        end repeat
        
        return output
    end tell
end run