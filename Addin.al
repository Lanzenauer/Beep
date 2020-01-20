controladdin beepAddin
{
    RequestedHeight = 300;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    Scripts =
             'JS\Makebeep.js',
             'https://code.jquery.com/jquery-2.1.0.min.js';
    StyleSheets = 'StyleSheet\StyleSheet.css';
    //StartupScript = 'JS\Start.js';
    Images = 'beep-02.mp3';
    event Ready()

     procedure makeBeep()
}