#Requires AutoHotkey v2.0

RAlt & c:: {
    ShiftState := GetKeyState("Shift", "P")
    If (ShiftState) {
        SendInput "⋮"
    } Else {
        SendInput "≡"
    }
}

RAlt & m:: SendInput "×"

RAlt & d:: SendInput "÷"

RAlt & u:: SendInput "∪"

RAlt & a:: {
    ShiftState := GetKeyState("Shift", "P")
    If (ShiftState) {
        SendInput "∀"
    } Else {
        SendInput "∘"
    }
}

RAlt & r:: {
    ShiftState := GetKeyState("Shift", "P")
    If (ShiftState) {
        SendInput "⍉"
    } Else {
        SendInput "⊥"
    }
}

RAlt & -:: SendInput "¬"

RAlt & s:: {
    ShiftState := GetKeyState("Shift", "P")
    If (ShiftState) {
        SendInput "⋄"
    } Else {
        SendInput "⟷"
    }
}

RAlt & =:: SendInput "≠"

RAlt & <:: SendInput "≤"

RAlt & >:: SendInput "≥"

RAlt & o:: {
    ShiftState := GetKeyState("Shift", "P")
    If (ShiftState) {
        SendInput "○"
    } Else {
        SendInput "≍"
    }
}

RAlt & p:: SendInput "⊑"

RAlt & f:: {
    ShiftState := GetKeyState("Shift", "P")
    If (ShiftState) {
        SendInput "⍷"
    } Else {
        SendInput "∊"
    }
}

RAlt & e:: SendInput "˝"

RAlt & n:: SendInput "→"

RAlt & g:: SendInput "Σ"
