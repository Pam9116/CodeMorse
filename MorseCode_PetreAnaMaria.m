

function MorseCodeGUI
    fig = uifigure('Name', 'CMGD', 'Position', [520, 525, 815, 275], 'Color', [0.99, 0.93, 0.0]);
    inputLabel = uilabel(fig, 'Text', 'Scrie Text:', 'Position', [230, 200, 80, 22], 'FontColor', [0.1, 0.14, 0.13], 'FontSize', 14);
    inputField = uieditfield(fig, 'Position', [300, 200, 200, 22], 'BackgroundColor', [1, 1, 1]);
    resultLabel = uilabel(fig, 'Text', 'Afiseaza:', 'Position', [230, 170, 80, 22], 'FontColor', [0.1, 0.14, 0.13], 'FontSize', 14);
    resultField = uieditfield(fig, 'Position', [300, 170, 200, 22], 'BackgroundColor', [1, 1, 1]);
    resultField.Editable = 'off';
    generateButton = uibutton(fig, 'Text', 'Generare Code', 'Position', [50, 130, 120, 30], 'ButtonPushedFcn', @(src, event) generateMorse(src, inputField, resultField), 'BackgroundColor', [0.36, 0.54, 0.66], 'FontColor', [1, 1, 1], 'FontSize', 14);
    decodeButton = uibutton(fig, 'Text', 'Decodare Morse', 'Position', [200, 130, 120, 30], 'ButtonPushedFcn', @(src, event) decodeMorse(src, inputField, resultField), 'BackgroundColor', [0.0, 0.0, 1.0], 'FontColor', [1, 1, 1], 'FontSize', 14);
    soundButton = uibutton(fig, 'Text', 'Sunet', 'Position', [350, 130, 120, 30], 'ButtonPushedFcn', @(src, event) playSound(src, resultField), 'BackgroundColor', [0.36, 0.54, 0.66], 'FontColor', [1, 1, 1], 'FontSize', 14);
    downloadButton = uibutton(fig, 'Text', 'Descarca Sunet', 'Position', [500, 130, 120, 30], 'ButtonPushedFcn', @(src, event) downloadSound(src, resultField), 'BackgroundColor', [0.0, 0.0, 1.0], 'FontColor', [1, 1, 1], 'FontSize', 14);
    loadButton = uibutton(fig, 'Text', 'Încarcă Fișier', 'Position', [650, 130, 120, 30], 'ButtonPushedFcn', @(src, event) loadAudio(src, resultField), 'BackgroundColor', [0.36, 0.54, 0.66], 'FontColor', [1, 1, 1], 'FontSize', 14);

end


function loadAudio(~, resultField)
    [filename, filepath] = uigetfile('*.wav', 'Selectați un fișier audio WAV');
    if filename
        fullFilePath = fullfile(filepath, filename);
        % [soundVector, fs] = audioread(fullFilePath);
        % 
        % morseCode = soundToMorse(soundVector, fs);
        resultField.Value = demorse(fullFilePath);
        
        disp('Codul Morse a fost extras din fișierul audio.');
    end
end



function downloadSound(~, resultField)
    morseCode = upper(resultField.Value); 
    soundVector = morseToSound(morseCode);
    filename = 'morse_code_sound.wav';
    audiowrite(filename, soundVector, 44100);
    
    disp(['Sunetul a fost salvat în fișierul ', filename]);
end

function playSound(~, resultField)
    morseCode = upper(resultField.Value);
    soundVector = morseToSound(morseCode);
    player = audioplayer(soundVector, 44100);
    playblocking(player); 
end

function soundVector = morseToSound(morseCode)
    dotDuration = 1.2/20; % Durata unui punct în secunde
    dashDuration = 3 * dotDuration; % Durata unei liniuțe
    gapDuration = 2 * dotDuration; % Durata unei pauze între caractere
    wordGapDuration = 4 * dotDuration; % Durata unei pauze între cuvinte
    soundVector = [];
    for i = 1:length(morseCode)
        if morseCode(i) == '.' 
            soundVector = [soundVector, generateSineWave(dotDuration, 2000)]; 
        elseif morseCode(i) == '-' 
            soundVector = [soundVector, generateSineWave(dashDuration, 2000)]; 
        elseif morseCode(i) == ' ' 
            soundVector = [soundVector, zeros(1, round(gapDuration * 44100))];
        elseif morseCode(i) == '/' 
            soundVector = [soundVector, zeros(1, round(wordGapDuration * 44100))]; 
        end
        soundVector = [soundVector, zeros(1, round(dotDuration * 44100 / 7))];
    end
end
function generateMorse(~, inputField, resultField)
    inputText = upper(inputField.Value);
    morseCode = textToMorse(inputText);
    resultField.Value = morseCode;
end

function decodeMorse(~, inputField, resultField)
    morseCode = upper(inputField.Value); 
    plainText = morseToText(morseCode);
    resultField.Value = plainText;
end


function morseCode = textToMorse(inputText)
    morseAlphabet = containers.Map(...
        {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'}, ...
        {'.-', '-...', '-.-.', '-..', '.', '..-.', '--.', '....', '..', '.---', '-.-', '.-..', '--', '-.', '---', '.--.', '--.-', '.-.', '...', '-', '..-', '...-', '.--', '-..-', '-.--', '--..', '.----', '..---', '...--', '....-', '.....', '-....', '--...', '---..', '----.', '-----'});
    
    morseCode = '';
    for i = 1:length(inputText)
        if isKey(morseAlphabet, inputText(i))
            morseCode = [morseCode, morseAlphabet(inputText(i)), ' '];
        else
            morseCode = [morseCode, ' '];
        end
    end
end

function plainText = morseToText(morseCode)
    morseAlphabet = containers.Map(...
        {'.-', '-...', '-.-.', '-..', '.', '..-.', '--.', '....', '..', '.---', '-.-', '.-..', '--', '-.', '---', '.--.', '--.-', '.-.', '...', '-', '..-', '...-', '.--', '-..-', '-.--', '--..', '.----', '..---', '...--', '....-', '.....', '-....', '--...', '---..', '----.', '-----'}, ...
        {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'});
    
    morseWords = strsplit(morseCode, '   '); 
    plainText = '';
    for i = 1:length(morseWords)
        morseChars = strsplit(morseWords{i}, ' ');
        for j = 1:length(morseChars)
            if isKey(morseAlphabet, morseChars{j})
                plainText = [plainText, morseAlphabet(morseChars{j})];
            else
                plainText = [plainText, ' '];
            end
        end
        plainText = [plainText, ' '];
    end
end
function sineWave = generateSineWave(duration, frequency)
    t = 0:1/8000:duration;
    sineWave = sin(2 * pi * frequency * t);
    f = 550; 
    wpm = 20; 
    ditDuration = 1.2 / wpm; 
    dahDuration = 3 * ditDuration; 
    Fs = 8000; 
end

function outstring = demorse(wavfile);

vis_on = 0;

threshold = 0.05;

x = audioread(wavfile);

x2 = abs(x);

y = filter(ones(1,20)/20,1, x2);

z = y > threshold;

if vis_on
   figure(1);
   subplot(3,1,1);
   plot(x, 'r');
   title('original signal');
   
   subplot(3,1,2);
   plot(y);
   title('HWR + Slow-wave filter -> envelope');
   subplot(3,1,3);
   plot(z, 'o', 'MarkerSize', 2);
   title('Digitized Morse signal')
   
end

z = [zeros(10,1); z];

b = diff(z);


c = b(b~=0);
c2 = find(b~=0);

tokens = -c .* diff([0; c2]);

tokens2 = tokens;

cut_t = mean(tokens2(tokens2>0));
cut_s = mean(tokens2(tokens2<0));

tokens2(tokens > 0 & tokens < cut_t) = 1;
tokens2(tokens > 0 & tokens > cut_t) = 2;
tokens2(tokens < 0 & tokens > cut_s) = -1;
tokens2(tokens < 0 & tokens < cut_s) = -2;

tokens2 = [tokens2(2:end); -2];

tokens2(tokens2 == -1) = [];
tokens3 = tokens2;
tokens4 = {};
ctr = 1;
start_idx = 1;


toparse = find(tokens3(start_idx:end) == -2);

for j=1:length(toparse)
   a = toparse(j);
   temp = tokens3(start_idx:a-1);
   tokens4{j} = temp;
  
   start_idx = a+1;

end
    

% letters
code{1} = [1 2 ];
code{2} = [2 1 1 1];
code{3} = [2 1 2 1];
code{4} = [2 1 1];
code{5} = [1];
code{6} = [1 1 2 1];
code{7} = [2 2 1];
code{8} = [1 1 1 1];
code{9} = [1 1];
code{10} = [1 2 2 2];
code{11} = [2 1 2];
code{12} = [1 2 1 1];
code{13} = [2 2];
code{14} = [2 1];
code{15} = [2 2 2];
code{16} = [1 2 2 1];
code{17} = [1 2 1 2];
code{18} = [1 2 1];
code{19} = [1 1 1];
code{20} = [2];
code{21} = [1 1 2]; 
code{22} = [1 1 1 2];
code{23} = [1 2 2];
code{24} = [2 1 1 2];
code{25} = [2 1 2 2];
code{26} = [2 2 1 1];

% punct
code{27} = [1 2 1 2 1 2];
code{28} = [2 2 1 1 2 2];
code{29} = [1 1 2 2 1 1];    
code{30} = [2 1 1 2 1];

% numbers

code{31} = [1 2 2 2 2];
code{32} = [1 1 2 2 2];
code{33} = [1 1 1 2 2];
code{34} = [1 1 1 1 2];
code{35} = [1 1 1 1 1];
code{36} = [2 1 1 1 1];
code{37} = [2 2 1 1 1];
code{38} = [2 2 2 1 1];
code{39} = [2 2 2 2 1];
code{40} = [2 2 2 2 2];


decode{1} = 'A';
decode{2} = 'B';
decode{3} = 'C';
decode{4} = 'D';
decode{5} = 'E';
decode{6} = 'F';
decode{7} = 'G';
decode{8} = 'H';
decode{9} = 'I';
decode{10} = 'J';
decode{11} = 'K';
decode{12} = 'L';
decode{13} = 'M';
decode{14} = 'N';
decode{15} = 'O';
decode{16} = 'P';
decode{17} = 'Q';
decode{18} = 'R';
decode{19} = 'S';
decode{20} = 'T';
decode{21} = 'U';
decode{22} = 'V';
decode{23} = 'W';
decode{24} = 'X';
decode{25} = 'Y';
decode{26} = 'Z';
decode{27} = '.';
decode{28} = ',';
decode{29} = '?';
decode{30} = '/';
decode{31} = '1';
decode{32} = '2';
decode{33} = '3';
decode{34} = '4';
decode{35} = '5';
decode{36} = '6';
decode{37} = '7';
decode{38} = '8';
decode{39} = '9';
decode{40} = '0';



out1 = [];

for j = 1:length(tokens4)
 
    temp_tok = [tokens4{j}; zeros(6 - length(tokens4{j}), 1)];
    for k = 1:length(code)
        if (temp_tok == [code{k}'; zeros(6 - length(code{k}), 1)]);
            out1(j) = char(decode{k});
           
        end

    end

 
    if isempty(out1(j))
        out1(j) = '_';
    end

outstring = 32*ones(2*length(out1),1);
outstring(2:2:end) = out1;
outstring = char(outstring');

end

end

