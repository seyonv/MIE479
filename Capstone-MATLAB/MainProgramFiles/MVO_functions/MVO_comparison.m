% This function takes in the asset allocatiosn of standard MVO and our custom inflation
% hedged model. It also tak

%% MVO_COMPARISON 
%{
    Take in the two MVO weightings, one for standard MVO and the other for
    inflation hedged MVO, then show their projected returns over the sample
    period, alongside the market returns for that period. 
    
    This function can be modified accodingly if more benchmark models are
    added.
    
    MVO_x: vector of weights corresponding to standard MVO w/ transactions
    inf_x: vector of weights corresponding to our model
    asset_returns: relevant for the relevant assets over the sample
    period
    market_returns: market returns 
%}
function [cumul_MVO cumul_inf cumul_SP cumul_MF1 cumul_MF2] = MVO_comparison( MVO_x, inf_x, projected_returns,...
    market_returns,MF_returns1,MF_returns2,startyear,endyear)

    
    [T n] = size(projected_returns);

    
    MVO_returns = projected_returns*MVO_x;
    inf_returns = projected_returns*inf_x;

    cumul_MVO(1) = MVO_returns(1);
    cumul_inf(1) = inf_returns(1);
    cumul_SP(1) = market_returns(1);
    cumul_MF1(1) = MF_returns1(1);
    cumul_MF2(1) = MF_returns2(1);


    for i = 2:T
        cumul_MVO(i) = (1+cumul_MVO(i-1))*(1+MVO_returns(i))  - 1;
        cumul_inf(i) = (1+cumul_inf(i-1))*(1+inf_returns(i)) - 1;
        cumul_SP(i) =  (1+cumul_SP(i-1))*(1+market_returns(i)) - 1;
        cumul_MF1(i) =  (1+cumul_MF1(i-1))*(1+MF_returns1(i)) - 1;
        cumul_MF2(i) =  (1+cumul_MF2(i-1))*(1+MF_returns2(i)) - 1;
    end

    portfolio_MVO=1 * (1 + cumul_MVO);
    portfolio_inf=1 * (1 + cumul_inf);
    portfolio_SP=1 * (1 + cumul_SP);

    figure
    plot(1:T,cumul_MVO*100, '-b');
    hold all
    plot(1:T,cumul_inf*100, '-r');
    hold all
    plot(1:T,cumul_SP*100, '-g');
    hold all
    plot(1:T,cumul_MF1*100, '-m');
    hold all
    plot(1:T,cumul_MF2*100, '-c');
    
  %  plot(1:T,currinfprices,'-m');

    h = {'Standard MVO', 'Inflation Hedged SF', 'S&P500',...
         'Vanguard Wellington Inv','CGM Mutual Fund'};
    h = legend(h);
     
    grid on;

    title(['Comparing Cumulative Returns of Optimal Portfolios and Market'...
        ,num2str(startyear),' to ',num2str(endyear)])
    xlabel('Time (in months)')
    ylabel('Cumulative Monthly Returns (in %)')
     

    figure
    plot(1:T,MVO_returns, '-b');
    hold all
    plot(1:T,inf_returns, '-r');
    hold all
    plot(1:T,market_returns,'-g');
    hold all
  %  plot(1:T,currinfprices, '-m');

    h = {'Standard MVO', 'Inflation Hedged SF', 'S&P500','inflation rate'};

    title(['Comparing Return Values of Optimal Portfolios and Market'...
        ,num2str(startyear),' to ',num2str(endyear)])
    xlabel('Time (in months)')
    ylabel('Monthly Returns')

  
    
    h = legend(h);
     
    grid on;
    
    hold all 
    
    
end

