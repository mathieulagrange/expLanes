function resultCell = expNumToCell(dataMean, dataVar, displayDigitPrecision, put, highlight, highlightColor)

if ~exist('dataVar', 'var'), dataVar = []; end
if ~exist('displayDigitPrecision', 'var'), displayDigitPrecision=0; end
if ~exist('put', 'var'), put=0; end
if ~exist('highlight', 'var'), highlight=0; end
if ~exist('number', 'var'), number=0; end

if put==2
    og = '$\\pm$';
    fg = '';
else
    og = ' (';
    fg = ')';
end

resultCell = cell(size(dataMean));

if length(displayDigitPrecision)< size(dataMean, 2)
    displayDigitPrecision = displayDigitPrecision(1)*ones(1, size(dataMean, 2));
end

for k=1:size(dataMean, 2)
    col=[];
    if  ~isempty(dataVar)
        dec = nansum(abs(dataVar(:, k)));
        if abs(dec) > eps*1000000 % && ~isnan(dec)
            col = cellstr(num2str([dataMean(:, k), dataVar(:, k)], ['%0.' num2str(displayDigitPrecision(k)) 'f' og '%0.' num2str(displayDigitPrecision(k)) 'f' fg ' \n']));
        end
    end
    if isempty(col)
        col = cellstr(num2str(dataMean(:, k), ['%10.' num2str(displayDigitPrecision(k)) 'f\n']));
    end
    col = regexprep(col, 'NaN', '-');
    resultCell(:, k) = regexprep(col, ' \(-\)', '');
end

if any(highlight(:))
    if put == 2
             resultCell(highlight==1) = strcat('\textbf{', resultCell(highlight==1), '}');
      switch highlightColor
          case 1
             resultCell(highlight==2) = strcat('\textbf{\textcolor{red}{', resultCell(highlight==2), '}}');
          case 0
             resultCell(highlight==2) = strcat('\textbf{', resultCell(highlight==2), '$^*$}');
           case -1
             resultCell(highlight==2) = strcat('\textbf{', resultCell(highlight==2), '}');
      end
    elseif put == 1
        %         resultCell(highlight==0) = strcat('<html><font color="black"><b>', resultCell(highlight==0), '</font></html>');
        resultCell(highlight==1) = strcat('<html><font color="blue"><b>', resultCell(highlight==1), '</font></html>');
        resultCell(highlight==2) = strcat('<html><font color="red"><b>', resultCell(highlight==2), '</font></html>');
    end
end


