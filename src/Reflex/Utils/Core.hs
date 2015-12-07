{-# LANGUAGE CPP, OverloadedStrings, ScopedTypeVariables, RecursiveDo #-}
#ifdef ghcjs_HOST_OS
{-# LANGUAGE ForeignFunctionInterface, JavaScriptFFI #-}
#endif
module Reflex.Utils.Core (
  accumReset,
  traceEventShow,
  rbutton,
#ifdef ghcjs_HOST_OS
  windowOpen
#endif
)

where

import Control.Monad.Fix
import Data.Monoid
import Reflex
import Reflex.Dom

import qualified Data.Map as M

#ifdef ghcjs_HOST_OS
import Control.Monad.IO.Class
import GHCJS.Marshal
import GHCJS.Types
import Network.URI
import qualified Data.Text as T
#endif

-- | Accumulate monoidal Events whilst allowing them to be reset by a separate Event
accumReset :: (Reflex t, MonadFix m, MonadHold t m, Monoid a) => Event t a -> Event t () -> m (Dynamic t a)
accumReset ea ereset = foldDyn ($) mempty $ leftmost [fmap (<>) ea, const mempty <$ ereset]

traceEventShow :: (Reflex t, Show a) => Event t a -> Event t a
traceEventShow = traceEvent "[EVENT_OCCURRED] "

-- rbuttonsel :: MonadWidget t m => String -> M.Map String String -> m (Event t ())
-- rbuttonsel = rbutton "sel" "nosel"

rbutton :: MonadWidget t m => String -> M.Map String String -> m (Event t ())
rbutton lbl attrs = mdo
  (elt, _) <- elDynAttr' "button" dattrs $ text lbl
  let eclick  = domEvent Click      elt
      -- eup     = domEvent Mouseup    elt
      -- edown   = domEvent Mousedown  elt
      -- eenter  = domEvent Mouseenter elt -- TODO, how do we know if mouse is still down on re-enter????
      -- eleave  = domEvent Mouseleave elt
  -- dsel     <- holdDyn False $ leftmost [True <$ edown, False <$ eup, False <$ eleave]
  -- dselcls  <- mapDyn (\flag -> if flag then sel else nosel) dsel
  -- dattrs   <- mapDyn (flip addClass attrs) dselcls
  dattrs   <- return $ constDyn attrs
  return eclick

-- addClass :: String -> M.Map String String -> M.Map String String
-- addClass c attrs = M.insert "class" cs attrs
--                      where
--                        cs = maybe c (\cls -> cls <> " " <> c) $ M.lookup "class" attrs

-- performRequestAsync :: (MonadWidget t m) => Event t XhrRequest -> m (Event t XhrResponse)
-- performRequestAsync req = performEventAsync $ ffor req $ \r cb -> do
--   _ <- newXMLHttpRequest r $ liftIO . cb
--   return ()

-- performAJAX
--     :: (MonadWidget t m)
--     => (a -> XhrRequest)  -- ^ Function to build the request
--     -> (XhrResponse -> b) -- ^ Function to parse the response
--     -> Event t a
--     -> m (Event t (a, b))
-- performAJAX mkRequest parseResponse req =
--     performEventAsync $ ffor req $ \a cb -> do
--       _ <- newXMLHttpRequest (mkRequest a) $ \response ->
--              liftIO $ cb (a, parseResponse response)
--       return ()


#ifdef ghcjs_HOST_OS
foreign import javascript unsafe "window['open']($1)" js_windowOpen :: JSRef a -> IO ()

windowOpen :: forall t m . MonadWidget t m => Event t URI -> m (Event t ())
windowOpen ev = performEventAsync (go <$> ev)
    where
      go :: URI -> (() -> IO ()) -> WidgetHost m ()
      go uri cb = do
              liftIO $ js_windowOpen =<< toJSRef (T.pack (show uri))
              liftIO $ cb ()
#endif

