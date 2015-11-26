module Reflex.Utils.Core (
  accumReset,
  traceEventShow
)

where

import Control.Monad.Fix
import Data.Monoid
import Reflex

-- | Accumulate monoidal Events whilst allowing them to be reset by a separate Event
accumReset :: (Reflex t, MonadFix m, MonadHold t m, Monoid a) => Event t a -> Event t () -> m (Dynamic t a)
accumReset ea ereset = foldDyn ($) mempty $ leftmost [fmap (<>) ea, const mempty <$ ereset]

traceEventShow :: (Reflex t, Show a) => Event t a -> Event t a
traceEventShow = traceEvent "[EVENT_OCCURRED] "


