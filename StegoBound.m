I = imread('D:\study_material_and_CV_and_research_papers\research_image\Mandrill_grey.png');


[BW, maskedImage] = segmentImage(I);
%sz = size(I);
%imshow (I);
%imhist(I);


bw_image = BW ;
%
% for (j= 1: numel(I))
%     if(I(j) <=125)
%         bw_image(j) = 0;
%     else
%         bw_image(j) = 1;
%     end
% end


% %imshow(bw_image);
% bw_image = imfill(bw_image);
% bw_image = imfill(bw_image,'holes');
% %imshow(bw_image);

%%%%%%%%%%for foreground and background pixels%%%%%%%%%%%%
%
% background_pixels = find(bw_image==0);
% background_pixels = background_pixels.';
% foreground_pixels = find(bw_image==1);
% foreground_pixels =foreground_pixels.';

%%%%%%%%for boundary pixels%%%%%%%%%%
boundary_pixels = bwboundaries(bw_image, 'noholes');
boundary_pixels = cell2mat(boundary_pixels);
[rows_1 cols_1] = size(boundary_pixels);
object_boundary_x_coords = boundary_pixels(1:rows_1,1);
object_boundary_y_coords = boundary_pixels(1:rows_1,2);






% improfile
% fig = gcf;
% axObjs = fig.Children;
% dataObjs = axObjs.Children;
%
%
% x = dataObjs(1).XData;
% y = dataObjs(1).YData;
% z = dataObjs(1).ZData;
%
%
% xt = transpose(x);
% yt = transpose(y);
% zt = transpose(z);
%
%
% background_pixels = [xt yt zt];
%
%
% background_pixels_mean = mean (background_pixels,2);
% background_pixels_final = round(background_pixels_mean);
% close all;
%
%
% imshow (I);
% boundary_pixels = impixel;
% boundary_pixels_mean = mean (boundary_pixels,2);
% boundary_pixels_final = round(boundary_pixels_mean);
% close all;
%
%
% imshow(I);
% foreground_pixels = impixel;
% foreground_pixels_mean = mean (foreground_pixels,2);
% foreground_pixels_final = round(foreground_pixels_mean);
% close all;
%






%[grayCoverImage, storedColorMap] = imread('D:\study_material_and_CV_and_research_papers\research_image\coins.png');
%grayCoverImage = imread('D:\study_material_and_CV_and_research_papers\research_image\coins.png');
grayCoverImage = I;
% This is the "cover" image - the readily apparent image that the viewer will see.
% This is the image that will "hide" the string.  In other words, our string will be hidden in this image
% so that all the viewer will notice is this cover image, and will not notice the text string.

% Get the dimensions of the image.
% numberOfColorBands should be = 1.
format long g;
format compact;
fontSize = 20;
% [rows, columns, numberOfColorChannels] = size(grayCoverImage);
% if numberOfColorChannels > 1
% 	% It's not really gray scale like we expected - it's color.
% 	% Convert it to gray scale by taking only the green channel.
% 	grayCoverImage = grayCoverImage(:, :, 2); % Take green channel.
% elseif ~isempty(storedColorMap)
% 	% There's a colormap, so it's an indexed image, not a grayscale image.
% 	% Apply the color map to turn it into an RGB image.
% 	grayCoverImage = ind2rgb(grayCoverImage, storedColorMap);
% 	% Now turn it into a gray scale image.
% 	grayCoverImage = uint8(255 * mat2gray(rgb2gray(grayCoverImage)));
% end
% [rows, columns, numberOfColorChannels] = size(grayCoverImage); % Update.  Only would possibly change, and that's if the original image was RGB or indexed.
% % Display the image.
hFig = figure;
subplot(1, 2, 1);
imshow(grayCoverImage, []);
axis on;
caption = sprintf('The Original Grayscale Image\nThe "Cover" Image.');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');

% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Get rid of tool bar and pulldown menus that are along top of figure.
set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'StegoBound Code', 'NumberTitle', 'Off')

%===============================================================================
% Get the string the user wants to hide:
hiddenString = 'This is your sample hidden string.';
% Ask user for a string.
defaultValue = hiddenString;
titleBar = 'Enter the string you want to hide';
userPrompt = 'Enter the string you want to hide';
caUserInput = inputdlg(userPrompt, titleBar, [1, length(userPrompt) + 75], {num2str(defaultValue)});
if isempty(caUserInput)
    % Bail out if they clicked Cancel.
    close(hFig);
    return;
end;
% Convert cell to character.
whos caUserInput;
hiddenString = cell2mat(caUserInput); % Could also use char() instead of cell2mat().
whos hiddenString;

%===============================================================================
% Get the bit plane the user wants to use to hide the message in.
% The lowest, least significant bit is numbered 1, and the highest allowable bit plane is 8.
% Values of 5 or more may allow the presence of a hidden text be noticeable in the image in the left column.
% Note: there is really no reason to use any other bit plane than the lowest one, unless you have more text than can fit in the image but then
% you'd have to use multiple bit planes instead of just one.  This is a very unlikely situation.
% Ask user for what bitplane they want to use.
defaultValue = 1;
titleBar = 'Enter the bit plane.';
userPrompt = 'Enter the bit plane you want to use (1 through 8)';
caUserInput = inputdlg(userPrompt, titleBar, [1, length(userPrompt) + 15], {num2str(defaultValue)});
if isempty(caUserInput),return,end; % Bail out if they clicked Cancel.
% Round to nearest integer in case they entered a floating point number.
integerValue = round(str2double(cell2mat(caUserInput)));
% Check for a valid integer.
if isnan(integerValue)
    % They didn't enter a number.
    % They clicked Cancel, or entered a character, symbols, or something else not allowed.
    integerValue = defaultValue;
    message = sprintf('I said it had to be an integer.\nI will use %d and continue.', integerValue);
    uiwait(warndlg(message));
end
bitToSet = integerValue; % Normal value is 1.
if bitToSet < 1
    bitToSet = 1;
elseif bitToSet > 8
    bitToSet = 8;
end

%===============================================================================
% Encode length of the string the user wants to use into the first 4 characters of the string:
% The first thing we need to do is to determine the number of characters in the string.
% Then we need to make some digits at the beginning of the string the length of the string
% so that we know how many pixels we need to read from the image when we try
% to extract the string from the image.  For example, if the string is "Hello World", that is 11 characters long
% Let's give 4 digits to the length of the string so we can handle up to strings of length 9999.
% So for our example string of 11 characters, we'd prepend 0011 to the string, and the new string would be
% "0011Hello World".  What we do is to first extract 4 characters from the image, and convert it to a number,
% 11 in our example.  Then we know that we need to read 11 additional characters, not the whole image.  This saves time.


%hiddenString = sprintf('%4.4d%s', length(hiddenString), hiddenString)

% Convert into the string's ASCII codes by using a trick of subtracting zero.
asciiValues = hiddenString - 0
% asciiValues = int32(hiddenString); % This also works.
% asciiValues = uint8(hiddenString); % This also works
stringLength = length(asciiValues);

%===============================================================================
% Make sure image is big enough to hold string.  Truncate string if necessary.
% Make sure the length of the string is less than the number of elements in the image divided by 7
% because we will encode each bit into the lowest bit of the pixel and there are 7 bits per ASCII letter/character.
numPixelsInImage = numel(grayCoverImage);
bitsPerLetter = 7;	% For ASCII, this is 7.
numPixelsNeededForString = stringLength * bitsPerLetter;
numPixelsNeededForString = ceil(numPixelsNeededForString/3);
if numPixelsNeededForString > numPixelsInImage
    warningMessage = sprintf('Your message is %d characters long.\nThis will require %d pixels,\nhowever your image has only %d pixels.\nI will use just the first %d characters.',...
        stringLength, numPixelsNeededForString, numPixelsInImage, numPixelsInImage);
    uiwait(warndlg(warningMessage));
    asciiValues = asciiValues(1:floor(numPixelsInImage/bitsPerLetter));
    stringLength = length(asciiValues);
    numPixelsNeededForString = stringLength * bitsPerLetter;

else
    message = sprintf('Your message is %d characters long.\nThis will require %d * %d = %d pixels,\nYour image has %d pixels so it will fit.',...
        stringLength, stringLength, bitsPerLetter, numPixelsNeededForString, numPixelsInImage);
    fprintf('%s\n', message);
    uiwait(helpdlg(message));
end

%===============================================================================
% Convert string to binary digits, zeros and ones.
% Convert from ASCII values in the range 0-255 to binary values of 0 and 1.
binaryAsciiString = dec2bin(asciiValues)'
whos binaryAsciiString
% Transpose it and string them all together into a row vector.
% This is the string we want to hide.  Each bit will go into one pixel.
binaryAsciiString = binaryAsciiString(:)'
% When you see it in the command window, the characters' ASCII codes will be vertical.  Each character is one column.

%===========================================================================================================




% HERE IS WHERE WE ACTUALLY HIDE THE TEXT MESSAGE
% Make a copy of our image because most pixels will be the same.  We only need to change those pixels that hold our string.


%%%===============================================================================%%%
%PART 1%
%%%===============================================================================%%%




if(numPixelsNeededForString <= numel(object_boundary_x_coords))
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                                                       %
    %                                                       %
    %                      EMBEDDING                        %
    %                                                       %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    stegoImage = grayCoverImage;
    c_v = 1; % short for counter variable
    %selected_pixel_array = zeros(numPixelsNeededForString,1);
    
    % First set all bits to 0;
    
    for i=1: 3 :(numel(binaryAsciiString)-2)
        stegoImage(object_boundary_x_coords(c_v),object_boundary_y_coords(c_v)) = bitset(stegoImage(object_boundary_x_coords(c_v),object_boundary_y_coords(c_v)),3, bin2dec(binaryAsciiString(i)));
        stegoImage(object_boundary_x_coords(c_v),object_boundary_y_coords(c_v)) = bitset(stegoImage(object_boundary_x_coords(c_v),object_boundary_y_coords(c_v)),2, bin2dec(binaryAsciiString(i+1)));
        stegoImage(object_boundary_x_coords(c_v),object_boundary_y_coords(c_v)) = bitset(stegoImage(object_boundary_x_coords(c_v),object_boundary_y_coords(c_v)),bitToSet, bin2dec(binaryAsciiString(i+2)));
        
        c_v = c_v+1;
%         %selected_pixel_array(counter_variable) = j;
%         if(counter_variable >=numel(object_boundary_x_coords))
%             disp(counter_variable)
%             disp('all boundary pixels are utilized now');
%             break;
%         end
    end
    %stegoImage(1:numPixelsNeededForString) = bitset(stegoImage(1:numPixelsNeededForString), bitToSet, 0);
    % Now set only the pixels that are 1 in the string, to 1 in the gray scale image.
    % First find, the linear indexes which have a 1 value in them.
    oneIndexes = find(binaryAsciiString == '1');
    counter_var = 1;
%     
%     
%     for (i =1: numel(object_boundary_x_coords))
%         if(i == oneIndexes(counter_var))
%             stegoImage(object_boundary_x_coords(i),object_boundary_y_coords(i)) = bitset(stegoImage(object_boundary_x_coords(i),object_boundary_y_coords(i)),3, 1);
%             stegoImage(object_boundary_x_coords(i),object_boundary_y_coords(i)) = bitset(stegoImage(object_boundary_x_coords(i),object_boundary_y_coords(i)),2, 1);
%             stegoImage(object_boundary_x_coords(i),object_boundary_y_coords(i)) = bitset(stegoImage(object_boundary_x_coords(i),object_boundary_y_coords(i)),bitToSet, 1);
%             counter_var = counter_var+3;
%             if(counter_var > numel(oneIndexes))
%                 break
%             end
%         end
%         if(counter_var > numel(oneIndexes))
%             break
%         end
%     end
%     
    % Then set only those indexes to 1 in the specified bit plane.
    %stegoImage(selected_pixel_array(oneIndexes)) = bitset(stegoImage(selected_pixel_array(oneIndexes)), bitToSet, 1);
    %===========================================================================================================
    
    %===========================================================================================================
    % Now stegoImage holds our string, hidden in the upper left column(s).
    % Display the steganography image.
    subplot(1, 2, 2);
    imshow(stegoImage, []);
    axis on;
    caption = sprintf('Image with your string hidden\nin the upper left column.');
    if bitToSet < 5
        caption = sprintf('%s\n(You will not be able to notice it.)', caption);
    end
    title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                                                       %
    %                                                       %
    %                      EXTRACTION                       %
    %                                                       %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % %===========================================================================================================
    % % HERE IS WHERE WE RECOVER THE HIDDEN TEXT MESSAGE FROM THE IMAGE.
    % % First we need to know how long the string is.  We encoded the string length into the first 4 characters of the string.
    % % Let's get those first 4 characters so we'll know how long the rest of the string is.
    %  numPixelsNeededForString_1 = 4 * bitsPerLetter;
    %
    %  retrievedBits = zeros(1,numPixelsNeededForString_1);
    %
    %  for l=1:numPixelsNeededForString_1
    %  retrievedBits(l) = bitget(stegoImage(object_boundary_x_coords(l),object_boundary_y_coords(l)), bitToSet);
    %  end
    %
    % % recoveredString = zeros(1,numPixelsNeededForString_1);
    %
    %  letterCount = 1;
    %  for k = 1 : bitsPerLetter : numPixelsNeededForString_1
    %  	% Get the binary bits for this one character.
    %  	thisString = retrievedBits(k:(k+bitsPerLetter-1));
    % % 	% Turn it from a binary string into an ASCII number (integer) and then finally into a character/letter.
    %  	thisChar = char(bin2dec(num2str(thisString)));
    %     disp(thisChar)
    % % 	% Store this letter as we build up the recovered string.
    %  	recoveredString(letterCount) = thisChar;
    %   	letterCount = letterCount + 1;
    %  end
    
    
    % stringLength_1 = str2double(recoveredString) + 4;
    % numPixelsNeededForString_2 = stringLength_1 * bitsPerLetter;
    
    retrievedBits_1 = zeros(1,numel(binaryAsciiString));
    
    c_v_1 = 1;
    % % Now we know that the length and string will be all contained in numPixelsNeededForString pixels.
    %
    % % Now try to extract the original hidden string, reading only as many pixels as we need to (what we learned in the first 4 characters).
    for l=1:3:(numel(binaryAsciiString)-2)
        retrievedBits_1(l) = bitget(stegoImage(object_boundary_x_coords(c_v_1),object_boundary_y_coords(c_v_1)), 3);
        retrievedBits_1(l+1) = bitget(stegoImage(object_boundary_x_coords(c_v_1),object_boundary_y_coords(c_v_1)), 2);
        retrievedBits_1(l+2) = bitget(stegoImage(object_boundary_x_coords(c_v_1),object_boundary_y_coords(c_v_1)), bitToSet);
        c_v_1 = c_v_1 +1;
    end
    %retrievedBits = bitget(stegoImage(1:numPixelsNeededForString_1), bitToSet);
    % % Reshape into a 2-D array
    
   % retrievedAsciiTable = reshape(retrievedBits_1, [bitsPerLetter, numPixelsNeededForString/bitsPerLetter]);
    
    % nextPixel = 4 * bitsPerLetter + 1;
    % Skip past the first 4 characters that had the length in them.
    letterCount = 1;
    for k = 1 : bitsPerLetter : numel(binaryAsciiString)
        % 	% Get the binary bits for this one character.
        thisString = retrievedBits_1(k:(k+bitsPerLetter-1));
        % 	% Turn it from a binary string into an ASCII number (integer) and then finally into a character/letter.
        thisChar = char(bin2dec(num2str(thisString)));
        % 	% Store this letter as we build up the recovered string.
        disp(thisChar)
        recoveredString_1(letterCount) = thisChar;
        letterCount = letterCount + 1;
    end
    %
    % %===========================================================================================================
    % % Now recoveredString contains the hidden, recovered string (without the first 4 characters which were the length of the string).
    % % Display a popup message to the user with the recovered string.
    message = sprintf('The recovered string = \n%s\n', recoveredString_1);
    fprintf('%s\n', message); % Also print to command window.
end
