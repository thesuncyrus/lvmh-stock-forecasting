"""Plot the price window and moving averages used by the analysis."""
from pathlib import Path
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
root=Path(__file__).resolve().parent
d=pd.read_csv(root/'data/LVMUY.csv',parse_dates=['Date'])
plt.rcParams.update({'font.family':'DejaVu Sans','svg.fonttype':'none','font.size':11,
 'axes.spines.top':False,'axes.spines.right':False,'figure.facecolor':'#faf9f6','axes.facecolor':'#faf9f6'})
fig,ax=plt.subplots(figsize=(10,5))
ax.plot(d.Date,d.Close,color='#a6afa5',lw=1,label='Daily close')
ax.plot(d.Date,d.Close.rolling(50).mean(),color='#28645b',lw=1.7,label='50 observations')
ax.plot(d.Date,d.Close.rolling(200).mean(),color='#b57036',lw=1.7,label='200 observations')
ax.set(title='LVMUY closing prices and moving averages',xlabel='Date',ylabel='Closing price (USD)')
ax.legend(frameon=False);fig.tight_layout(pad=2)
fig.savefig(root/'results/figures/prices.svg',metadata={'Date':None})
