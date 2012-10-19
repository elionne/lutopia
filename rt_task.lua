
tasks = {}
tasks.next = tasks
tasks.prev = tasks
tasks.v = {time= 0}

function add_task(func, step, total_time, name)

    local value = {func = func,
                   step = step,
                   p = 0,
                   total_time = total_time,
                   time = total_time * step,
                   name = name}

    local link = {next = tasks, v = value, prev = tasks.prev}
    link.prev.next = link
    tasks.prev = link

end

function swap_task(a, b)
    a.v, b.v = b.v, a.v
    a.locked, b.locked = b.locked, a.locked
end

function advance_train(c)
    if c ~= task then
        if c.next.locked ~= true then
            swap_task(c, c.next)
            --print(c.v.time, c.next.v.time)
            if c.prev == tasks then
                c.locked = true
                return
            end
            if c.prev.locked ~= true then
                advance_train(c.prev.prev)
            end
            if c.v.time >= c.prev.v.time then
                c.locked = true
            end
        end
    end
end

function finnish(c)
    c = c.prev
    if c ~= tasks then
        if c.locked ~= true then
            advance_train(c.prev)
        end
        finnish(c)
    end
end

function sort_by_time(t)
    local c = t.next
    c.locked = true

    repeat
        if c.v.time <= c.next.v.time then
            c.locked = true
        else
            advance_train(c)
        end
        c = c.next

    until c == t.prev
    c.locked = true

    finnish(t)
end

function decrease_time(diff)
    local current = tasks.next

    --Reset time only for the first to avoid to reset uncalled function
    current.v.time = current.v.time - diff
    current.locked = false
    if current.v.time <= 1e-9 then
        current.v.time = current.v.total_time * current.v.step
    end

    current = current.next

    repeat
        current.v.time = current.v.time - diff
        current.locked = false
        current = current.next
    until current == tasks

    return todo
end


function rt_time()
--    while true do
        sort_by_time(tasks)

        current = tasks.next.v
        local sleep_time = math.min(current.time, current.total_time * current.step)
        usleep(sleep_time*1e6)

        current.func(current.p)
        --print_tasks()
        current.p = current.p + current.step
        if current.p > 1 then current.p = 0 end

        decrease_time(sleep_time)
--    end

end

function print_tasks()
    local c = tasks.next
    repeat
        print(string.format("%.2f %f %s", c.v.time, c.v.total_time * c.v.step, c.v.name))
        c = c.next
    until c == tasks
    print ""
end

function start_task(func)

    --[[
    add_task(function(p) print("b", p) end, 0.5, 8, "b")
    add_task(function(p) print("c", p) end, 1,   7, "c")
    add_task(function(p) print("d", p) end, 0.5, 6, "d")
    add_task(function(p) print("e", p) end, 1,   5, "e")
    add_task(function(p) print("f", p) end, 0.05, 4, "f")
    add_task(function(p) print("g", p) end, 0.4, 3, "g")
    add_task(function(p) print("h", p) end, 0.05, 2, "h")
    add_task(function(p) print("i", p) end, 0.1, 1, "i")
]]
   
    rt_time()

end
