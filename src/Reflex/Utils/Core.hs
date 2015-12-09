{-# LANGUAGE CPP, OverloadedStrings, ScopedTypeVariables, RecursiveDo #-}
#ifdef ghcjs_HOST_OS
{-# LANGUAGE ForeignFunctionInterface, JavaScriptFFI #-}
#endif
module Reflex.Utils.Core (
  accumReset,
  holdReset,
  traceEventShow,
  rbutton,
  windowOpen,
  windowLocationHref
)

where

import Control.Monad.Fix
import Data.Monoid
import Reflex
import Reflex.Dom

import qualified Data.Map as M
import qualified Data.Text as T

#ifdef ghcjs_HOST_OS
import Control.Monad.IO.Class
import Data.Functor (($>))
import GHCJS.Foreign
import GHCJS.Types
#endif

-- | Accumulate monoidal Events whilst allowing them to be reset by a separate Event
accumReset :: forall a t m . (Reflex t, MonadFix m, MonadHold t m, Monoid a) => Event t a -> Event t () -> m (Dynamic t a)
accumReset ea ereset = foldDyn ($) mempty
                         (leftmost [fmap (<>) ea, const mempty <$ ereset] :: Event t (a -> a))

-- | Hold the most recent occurrence (if any) and allow for reset
holdReset :: forall a t m . (Reflex t, MonadFix m, MonadHold t m) => Event t a -> Event t () -> m (Dynamic t (Maybe a))
holdReset ea ereset = foldDyn ($) Nothing
                        (leftmost [const . Just <$> ea, const Nothing <$ ereset] :: Event t (Maybe a -> Maybe a))

traceEventShow :: (Reflex t, Show a) => Event t a -> Event t a
traceEventShow = traceEvent "[EVENT_OCCURRED] "

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
foreign import javascript unsafe "window['open']($1)" js_windowOpen :: JSString -> IO (JSRef a)
-- | Accept 'T.Text' rather than URI because we want to be able to handle relative URLs
windowOpen :: forall t m a . MonadWidget t m => Event t T.Text -> m (Event t (JSRef a))
windowOpen ev = performEventAsync (ffor ev $ \uri cb -> liftIO $ cb =<< (js_windowOpen $ toJSString uri))
#else
windowOpen :: forall t m a. MonadWidget t m => Event t T.Text -> m (Event t a)
windowOpen = error "Reflex.Utils.Core:windowOpen - only implemented for JS"
#endif


#ifdef ghcjs_HOST_OS
foreign import javascript unsafe "window['location']['href']" js_windowLocationHref :: IO JSString
windowLocationHref :: forall t m . MonadWidget t m => Event t () -> m (Event t T.Text)
windowLocationHref ev = performEventAsync (ev $> (\cb -> liftIO $ cb . fromJSString =<< js_windowLocationHref))
#else
windowLocationHref :: forall t m . MonadWidget t m => Event t () -> m (Event t T.Text)
windowLocationHref = error "Reflex.Utils.Core:windowLocationHref - only implemented for JS"
#endif

