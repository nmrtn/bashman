
declare -a heap_values
declare -a heap_prios

function heap_init() {
    heap_values=(0)
    heap_prios=(0)
}

function heap_add() {
    local v=$1
    local p=$2
    local len=${#heap_values[@]}

    heap_values[$len]="$v"
    heap_prios[$len]="$p"

    heap_bubbleup
}

function heap_remove() {
    local i=$((${#heap_values[@]}-1))
    local result=${heap_values[1]}

    if (( i == 0 )); then
        return
    fi

    heap_values[1]=${heap_values[$i]}
    heap_prios[1]=${heap_prios[$i]}

    unset heap_values[$i]
    unset heap_prios[$i]

    heap_bubbledown
}

function heap_bubbledown() {

    local i=1
    local len=${#heap_values[@]}

    while (( i*2 < len )); do
        local smaller=$((i*2))
        if (( i*2+1 < len )) && (( heap_prios[i*2] > heap_prios[i*2+1] )); then
            ((smaller=i*2+1))
        fi
        if (( heap_prios[i] > heap_prios[smaller] )); then
            heap_swap $i $smaller
        else
            break
        fi
        i=$smaller
    done
}

function heap_bubbleup() {
    local i=$((${#heap_values[@]}-1))
    local prio

    (( prio = heap_prios[i] ))

    while (( i > 1 )) && (( heap_prios[i/2] > prio )); do
        heap_swap $i $((i/2))
        (( i = i/2 ))
    done
}

function heap_swap() {
    local a="$1"
    local b="$2"
    local tmp
    
    tmp="${heap_values[$a]}"
    heap_values[$a]="${heap_values[$b]}"
    heap_values[$b]="$tmp"

    tmp="${heap_prios[$a]}"
    heap_prios[$a]="${heap_prios[$b]}"
    heap_prios[$b]="$tmp"
}

