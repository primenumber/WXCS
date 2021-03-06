module OnlineJudge where

import qualified OnlineJudge.Aoj as Aoj

import Config
import ModelTypes

submit :: Configuration
          -> JudgeType -- Judge type
          -> String -- problem id
          -> String -- language
          -> String -- code
          -> IO Bool
submit conf Aizu = Aoj.submit (aoj conf)

fetchByRunId :: Configuration
                -> JudgeType -- judge type
                -> Int -- run id
                -> IO (Maybe (JudgeStatus, String, String))
fetchByRunId conf Aizu = Aoj.fetchByRunId (aoj conf)

getLatestRunId :: Configuration
                  -> JudgeType -- judge type
                  -> IO Int
getLatestRunId conf Aizu = Aoj.getLatestRunId (aoj conf)

getDescriptionURL :: JudgeType
                     -> String -- problem id
                     -> String
getDescriptionURL Aizu n = "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=" ++ n
