function resultCell = expNumToCell(dataMean, dataVar, displayDigitPrecision, latexStyle, highlight)

if ~exist('dataVar', 'var'), dataVar = []; end
if ~exist('displayDigitPrecision', 'var'), displayDigitPrecision=0; end
if ~exist('latexStyle', 'var'), latexStyle=0; end
if ~exist('highlight', 'var'), highlight=0; end

if latexStyle
    og = '$\\pm$';
    fg = '';
else
    og = ' (';
    fg = ')';
end

resultCell = cell(size(dataMean));
for k=1:size(dataMean, 2)
    col=[];
    if  ~isempty(dataVar)
        dec = nansum(abs(dataVar(:, k)));
        if abs(dec) > eps*1000000 % && ~isnan(dec)
            col = cellstr(num2str([dataMean(:, k), dataVar(:, k)], ['%0.' num2str(displayDigitPrecision) 'f' og '%0.' num2str(displayDigitPrecision) 'f' fg ' \n']));
        end
    end
    if isempty(col)
        col = cellstr(num2str(dataMean(:, k), ['%10.' num2str(displayDigitPrecision) 'f\n']));
    end
    col = regexprep(col, 'NaN', '-');
     resultCell(:, k) = regexprep(col, ' \(-\)', '');
end

if any(highlight(:))
    if latexStyle
        resultCell(highlight==1) = strcat('\textbf{', resultCell(highlight==1), '}');
    else
%         resultCell(highlight==0) = strcat('<html><font color="black"><b>', resultCell(highlight==0), '</font></html>');
        resultCell(highlight==1) = strcat('<html><font color="purple"><b>', resultCell(highlight==1), '</font></html>');
    end
end

