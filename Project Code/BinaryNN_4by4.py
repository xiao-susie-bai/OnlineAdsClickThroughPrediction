# -*- coding: utf-8 -*-
"""
Created on Sun Dec 15 11:40:31 2019

@author: Julie Wang
"""
#%% Get Data

import numpy as np
import pandas as pd
import random as rn
import tensorflow as tf
from keras import backend as K
from keras import optimizers

NEpochs = 1000
BatchSize=250
Optimizer=optimizers.RMSprop(lr=0.01)

def SetTheSeed(Seed):
    np.random.seed(Seed)
    rn.seed(Seed)
    session_conf = tf.ConfigProto(intra_op_parallelism_threads=1,inter_op_parallelism_threads=1)

    tf.set_random_seed(Seed)

    sess = tf.Session(graph=tf.get_default_graph(), config=session_conf)
    K.set_session(sess)

# Read in the data
TrainData = pd.read_csv('Train100k_fixedsplit.csv',sep=',',header=0,quotechar='"')
ValData = pd.read_csv('Val100k_fixedsplit.csv',sep=',',header=0,quotechar='"')

Vars = list(TrainData)

YTr = np.array(TrainData[Vars[-1]])
XTr = np.array(TrainData.loc[:,Vars[:57]])

YVal = np.array(ValData[Vars[-1]])
XVal = np.array(ValData.loc[:,Vars[:57]])

# do not need to rescale

# YVal does not need to be rescaled as it is binary.
#%% Set up Neural Net Model - 4 layers of 4, but we need to experiment how many layers and nodes

#SetTheSeed(3456)

from keras.models import Sequential
from keras.layers import Dense, Activation

BCNN = Sequential()

BCNN.add(Dense(units=4,input_shape=(XTr.shape[1],),activation="relu",use_bias=True))
BCNN.add(Dense(units=4,activation="relu",use_bias=True))
BCNN.add(Dense(units=4,activation="relu",use_bias=True))
BCNN.add(Dense(units=4,activation="relu",use_bias=True))
BCNN.add(Dense(units=1,activation="sigmoid",use_bias=True))

BCNN.compile(loss='binary_crossentropy', optimizer=Optimizer,metrics=['binary_crossentropy'])

#%% Fit NN Model

FitHist = BCNN.fit(XTr,YTr,epochs=NEpochs,batch_size=BatchSize,verbose=0)
print("Number of Epochs = "+str(len(FitHist.history['binary_crossentropy'])))
FitHist.history['binary_crossentropy'][-1]
FitHist.history['binary_crossentropy'][-10:-1]
#%% Make Predictions
YHatTr = BCNN.predict(XTr,batch_size=XTr.shape[0]) # Note: Not scaled, so not necessary to undo.
YHatTr = YHatTr.reshape((YHatTr.shape[0]),)

YHatVal = BCNN.predict(XVal,batch_size=XVal.shape[0])
YHatVal = YHatVal.reshape((YHatVal.shape[0]),)

#%% Make Predictions
TrOutDF = pd.DataFrame(data={ 'YHatTr': YHatTr})

ValOutDF = pd.DataFrame(data={ 'YHatVal': YHatVal})

TrOutDF.to_csv('TrYHatFromBCNN4x4_100K.csv',sep=',',na_rep="NA",header=True,index=False)
ValOutDF.to_csv('ValYHatFromBCNN4x4_100k.csv',sep=',',na_rep="NA",header=True,index=False)





























