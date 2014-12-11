function data = getStockInformation(tickers)
%% function getStockInformation obtains stock informations
% PURPOSE: function getStockInformation obtains stock information with Yahoo! Query Languae from Yahoo.
%
% USAGE: data = getStockInformation({'GOOG','MSFT'});
% 
% REFERENCE: http://www.yqlblog.net/blog/2009/06/02/getting-stock-information-with-yql-and-open-data-tables/
%
% $Revision: 1.0 $ $Date: 2011/10/10 06:00$ $Author: Pangyu Teng $
% $Revision: 1.1 $ $Date: 2012/08/26 16:00$ $Author: Pangyu Teng $ Corrected line 24 $

if nargin<1
    display('getStockInformation.m requires 1 input parameter!');
    return;
end

display(sprintf('Connecting to Yahoo.com, please wait.... (getStockInformation.m)'));

%'blockproc' like process.
blockSz = 200;
data = [];
if numel(tickers) <= blockSz,
    
    data = getStockInformationCore(tickers);
    
else
    
   for i = 1:ceil(numel(tickers)/blockSz)
        if i<ceil(numel(tickers)/blockSz)
            ind = [(i-1)*blockSz+1:i*blockSz];
        elseif i == ceil(numel(tickers)/200)
            ind = [(i-1)*blockSz+1:numel(tickers)];
        end
        data = [data; getStockInformationCore(tickers(ind))];
        display(sprintf('%1.0f%% finished  (getStockInformation.m)',100*i/ceil(numel(tickers)/blockSz)'));
   end
   
end

function data = getStockInformationCore(tickers)

%import java classes
import java.io.*;
import java.net.*;
import java.lang.*;

%import XPath classes, for searching and parsing
import javax.xml.xpath.*;

%get portfolio info from google in xml format.
success=false;
MAXITER=3;
try
    % try to create new event
    safeguard=0;    
    while (~success && safeguard<MAXITER)
        %build URL
        geturlString = 'http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%22';
        for tickerCount = 1:numel(tickers)
            %format end of getURLstring depending on number of tickers.
            if tickerCount == numel(tickers),
                geturlString = [geturlString, tickers{tickerCount}];
            else
                geturlString = [geturlString, tickers{tickerCount}, '%22%2C%22'];
            end
        end
        geturlString = [geturlString,'%22)%0A%09%09&diagnostics=true&env=http%3A%2F%2Fdatatables.org%2Falltables.env'];
        
        %establish URL connection.
        url = URL( geturlString );
        con = url.openConnection();    
        con.setInstanceFollowRedirects(false);
        con.setRequestMethod( 'GET' );        
        con.setRequestProperty('content-type','application/atom+xml;charset=UTF-8');

        %continue if response is okay.
        if con.getResponseCode() == 200,
            success = true;
            continue;
        else
            display(sprintf('failed! http code: %d',con.getResponseCode()));
            con.disconnect();
            success=false;
            data =[];
            return;
        end
        safeguard = safeguard + 1;
    end
catch ME
    display(ME.message);
    success=false;
    data =[];
    return;
end

%read retrieved xml data.
xmlData=xmlread(con.getInputStream());
 %%show xml data.
 %xmlstr = xmlwrite(xmlData)

%disconnect connection.
con.disconnect();

data=struct([]);

%find value of for every item under <quote>.
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

%locate attribute names under first quote 
expression = xpath.compile('/query/results/quote[1]/*');
nodeList = expression.evaluate(xmlData,XPathConstants.NODESET);
numFields = nodeList.getLength; %number of attribues;
fieldNames=cell(nodeList.getLength,1); 
for i = 1:nodeList.getLength
    fieldNames{i}=char(nodeList.item(i-1).getNodeName);
end

%locate attributes under all quotes
expression = xpath.compile('/query/results/quote/*');
nodeList = expression.evaluate(xmlData,XPathConstants.NODESET);
totalFieldVales = nodeList.getLength;
infoCellArray=cell([totalFieldVales,1]);
%iterate through the nodes, get values that are returned.
for i = 1:totalFieldVales
    if ~isempty(nodeList.item(i-1).getFirstChild)
        infoCellArray{i} = char(nodeList.item(i-1).getFirstChild.getNodeValue);
    else
        infoCellArray{i} = 'NaN';    
    end
end

%gets number of quotes.
expression = xpath.compile('/query/results/quote/@symbol');
nodeList = expression.evaluate(xmlData,XPathConstants.NODESET);
numTickers = nodeList.getLength;

%reshape data.
infoCellArray = reshape(infoCellArray,[numFields,numTickers]);

%convert some cells to nums
infoCellArray  = setFieldsToNums(infoCellArray,fieldNames);

%convert cell to struct.
data = cell2struct(infoCellArray,fieldNames,1);

%format content of cell from string to number.
function data = setFieldsToNums(data,fieldNames)

    %get the names of the fields that contain numbers.
    numFieldNames = getNumFields();
    
    for i = 1:numel(fieldNames)
        %convert strings to numbers
        if sum(strcmp(fieldNames{i},numFieldNames))
             data(i,:)= cellfun(@str2num,data(i,:),'UniformOutput',false);
        end
    end

function output = getNumFields()
output = {'Ask','AverageDailyVolume',...
    'Bid',...
    'AskRealtime',...
    'BidRealtime',...
    'BookValue',...
    'Change',...
    'ChangeRealtime',...
    'DividendShare',...
    'EarningsShare',...
    'EPSEstimateCurrentYear','EPSEstimateNextYear','EPSEstimateNextQuarter',...
    'DaysLow','DaysHigh','YearLow','YearHigh',...
    'AnnualizedGain','HoldingsGain',...
    'OrderBookRealtime',... %'MarketCapitalization','MarketCapRealtime','EBITDA',...
    'ChangeFromYearLow',...%'PercentChangeFromYearLow',...
    'ChangeFromYearHigh',...
    'LastTradePriceOnly','HighLimit','LowLimit',...
    'FiftydayMovingAverage','TwoHundreddayMovingAverage','ChangeFromTwoHundreddayMovingAverage',...
    'ChangeFromFiftydayMovingAverage',...
    'Open','PreviousClose',... %'ChangeinPercent',
    'PriceSales','PriceBook','PERatio',... %,'ExDividendDate'
    'PERatioRealtime','PEGRatio','PriceEPSEstimateCurrentYear',... %'DividendPayDate',
    'PriceEPSEstimateNextYear','ShortRatio','OneyrTargetPrice','Volume',...
    };