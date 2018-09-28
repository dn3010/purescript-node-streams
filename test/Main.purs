module Test.Main where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromJust, isNothing, isJust)
import Effect (Effect)
import Effect.Console (log)
import Node.Buffer as Buffer
import Node.Encoding (Encoding(..))
import Node.Stream (Duplex, Readable, Writable, end, writeString, pipe, onData, setEncoding, setDefaultEncoding, read, onReadable)
import Partial.Unsafe (unsafePartial)
import Test.Assert (assert, assert')

main :: Effect Unit
main = pure unit
