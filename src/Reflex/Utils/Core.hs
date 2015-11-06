module Reflex.Utils.Core (
  traceEventShow
)

where

import Reflex

traceEventShow :: (Reflex t, Show a) => Event t a -> Event t a
traceEventShow = traceEvent "[EVENT_OCCURRED] "

