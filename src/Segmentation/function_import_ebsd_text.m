function dataArray = function_import_ebsd_text(filename, startRow, endRow)
%function_import_ebsd_text extracts ebsd text information
%   dataArray = function_import_ebsd_text(filename) find filename in same
%       directory and returns the cell array dataArray, where each column
%       is a vector of values from a column in the text file
%   
%   Inputs
%       filename - file name of EBSD text file
%       startRow (optional) - row to begin reading data, should not change
%       endRow (optional) - should be determined by code, use if getting
%       errors

%   Outputs
%       dataArray - Column array containing all text info%   
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    % Initialize variables.
    if nargin<=2
        startRow = 18;
        endRow = inf;
    end

    % Format for each line of text:
    formatSpec = '%9f%10f%10f%13f%13f%8f%7f%6f%6f%3f%[^\n\r]';

    % Open the text file.
    fileID = fopen(filename,'r');

    % Read columns of data according to the format.
    dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for block=2:length(startRow)
        frewind(fileID);
        dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
        for col=1:length(dataArray)
            dataArray{col} = [dataArray{col};dataArrayBlock{col}];
        end
    end

    fclose(fileID);
end