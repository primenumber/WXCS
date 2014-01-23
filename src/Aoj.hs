{-# LANGUAGE FlexibleContexts, OverloadedStrings #-}
module Aoj where

import Control.Monad.IO.Class (liftIO)
import Control.Monad.Trans.Class (lift)

import Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as BC
import qualified Data.Conduit as C
import qualified Data.Conduit.List as CL

import qualified Network.HTTP.Conduit as H
import qualified Network.HTTP.Types as HT

endpoint :: String
endpoint = "http://judge.u-aizu.ac.jp/onlinejudge/servlet/Submit"

userId :: ByteString
userId = "wxcs"

password :: ByteString
password = "wxcswxcs"

mkRequest :: HT.Method
             -> String
             -> HT.SimpleQuery
             -> IO H.Request
mkRequest m url query = do
  req <- H.parseUrl url
  return $ req { H.method = m
               , H.queryString = HT.renderSimpleQuery False query }

mkQuery user pass pid lang src =
  [("userID"    , user),
   ("password"  , pass),
   ("language"  , lang),
   ("problemNO" , pid),
   ("sourceCode", src)]
  
api :: (C.MonadBaseControl IO m, C.MonadResource m)
       => HT.Method
       -> String
       -> HT.SimpleQuery
       -> H.Manager
       -> m (H.Response (C.ResumableSource m ByteString))
api m url query mgr = do
  req <- liftIO $ H.parseUrl url
  let request = req { H.method = m,
                      H.queryString = HT.renderSimpleQuery False query }
  H.http request mgr

submit :: (C.MonadBaseControl IO m, C.MonadResource m)
          => ByteString -- problem id
          -> ByteString -- language
          -> ByteString -- code
          -> H.Manager
          -> m (H.Response (C.ResumableSource m ByteString))
submit pid lang src =
  api "POST" endpoint (mkQuery userId password pid lang src)

mkStatusQuery :: String -> Maybe Int -> HT.SimpleQuery
mkStatusQuery userId problemId =
  case problemId of
    Just id -> [("user_id", BC.pack userId), ("problem_id", BC.pack $ show id)]
    Nothing -> [("user_id", BC.pack userId)]

status :: (C.MonadBaseControl IO m, C.MonadResource m)
          => String -- User ID
          -> Maybe Int -- Problem ID
          -> H.Manager
          -> m (H.Response (C.ResumableSource m ByteString))
status userId problemId =
  api "GET" "http://judge.u-aizu.ac.jp/onlinejudge/webservice/status_log" (mkStatusQuery userId problemId)

showAll :: C.Sink ByteString (C.ResourceT IO) ()
showAll = CL.mapM_ (\s -> lift . putStrLn $ BC.unpack s)

main :: IO ()
main = H.withManager $ \mgr -> do
  res <- submit "0000" "C" "int main(){return 0;}" mgr
  res <- status "wxcs" Nothing mgr
  liftIO $ putStrLn $ show (H.responseStatus res)
  H.responseBody res C.$$+- showAll
