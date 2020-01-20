 var localAudio = new Audio(Microsoft.Dynamics.NAV.GetImageResource("beep-02.mp3"));

function makeBeep() {
    window.alert("Beep");
    localAudio.play();
}