-- | This module provides a low-level wrapper for the [Node Stream API](https://nodejs.org/api/stream.html).

module Node.Stream
  ( Stream()
  , Read()
  , Readable()
  , Write()
  , Writable()
  , Duplex()
  , Chunk
  , onData
  , setEncoding
  , onReadable
  , onEnd
  , onFinish
  , onClose
  , onError
  , resume
  , pause
  , isPaused
  , pipe
  , unpipe
  , unpipeAll
  , read
  , write
  , writeString
  , cork
  , uncork
  , setDefaultEncoding
  , end
  , destroy
  ) where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromMaybe)
import Effect (Effect)
import Effect.Exception (throw, Error)
import Effect.Uncurried (EffectFn1, EffectFn2, EffectFn4, mkEffectFn1, runEffectFn2, runEffectFn4)
import Node.Buffer (Buffer)
import Node.Buffer as Buffer
import Node.Encoding (Encoding)

-- | A stream.
-- |
-- | The type arguments track, in order:
-- |
-- | - Whether reading and/or writing from/to the stream are allowed.
-- | - Effects associated with reading/writing from/to this stream.
foreign import data Stream :: # Type -> Type

-- | A phantom type associated with _readable streams_.
data Read

-- | A readable stream.
type Readable r = Stream (read :: Read | r)

-- | A phantom type associated with _writable streams_.
data Write

-- | A writable stream.
type Writable r = Stream (write :: Write | r)

-- | A duplex (readable _and_ writable stream)
type Duplex = Stream (read :: Read, write :: Write)

foreign import undefined :: forall a. a

foreign import data Chunk :: Type

onData
  :: forall w
   . Readable w
  -> (Chunk -> Effect Unit)
  -> Effect Unit
onData r cb = runEffectFn2 onDataImpl r (mkEffectFn1 cb)

foreign import onDataImpl
  :: ∀ r
   . EffectFn2
       (Readable r)
       (EffectFn1 Chunk Unit)
       Unit

read
  :: ∀ w
   . Readable w
  -> Maybe Int
  -> Effect (Maybe Chunk)
read r size = runEffectFn4 readImpl Nothing Just r (fromMaybe undefined size)

foreign import readImpl
  :: ∀ r
   . EffectFn4
        (∀ a. Maybe a)
        (∀ a. a -> Maybe a)
        (Readable r)
        Int
        (Maybe Chunk)

foreign import setEncodingImpl
  :: forall w
   . Readable w
  -> String
  -> Effect Unit

-- | Set the encoding used to read chunks as strings from the stream. This
-- | function may be useful when you are passing a readable stream to some other
-- | JavaScript library, which already expects an encoding to be set.
setEncoding
  :: forall w
   . Readable w
  -> Encoding
  -> Effect Unit
setEncoding r enc = setEncodingImpl r (show enc)

-- | Listen for `readable` events.
foreign import onReadable
  :: forall w
   . Readable w
  -> Effect Unit
  -> Effect Unit

-- | Listen for `end` events.
foreign import onEnd
  :: forall w
   . Readable w
  -> Effect Unit
  -> Effect Unit

-- | Listen for `finish` events.
foreign import onFinish
  :: forall w
   . Writable w
  -> Effect Unit
  -> Effect Unit

-- | Listen for `close` events.
foreign import onClose
  :: forall w
   . Stream w
  -> Effect Unit
  -> Effect Unit

-- | Listen for `error` events.
foreign import onError
  :: forall w
   . Stream w
  -> (Error -> Effect Unit)
  -> Effect Unit

-- | Resume reading from the stream.
foreign import resume :: forall w. Readable w -> Effect Unit

-- | Pause reading from the stream.
foreign import pause :: forall w. Readable w -> Effect Unit

-- | Check whether or not a stream is paused for reading.
foreign import isPaused :: forall w. Readable w -> Effect Boolean

-- | Read chunks from a readable stream and write them to a writable stream.
foreign import pipe
  :: forall r w
   . Readable w
  -> Writable r
  -> Effect (Writable r)

-- | Detach a Writable stream previously attached using `pipe`.
foreign import unpipe
  :: forall r w
   . Readable w
  -> Writable r
  -> Effect Unit

-- | Detach all Writable streams previously attached using `pipe`.
foreign import unpipeAll
  :: forall w
   . Readable w
  -> Effect Unit

-- | Write a Buffer to a writable stream.
foreign import write
  :: forall r
   . Writable r
  -> Buffer
  -> Effect Unit
  -> Effect Boolean

foreign import writeStringImpl
  :: forall r
   . Writable r
  -> String
  -> String
  -> Effect Unit
  -> Effect Boolean

-- | Write a string in the specified encoding to a writable stream.
writeString
  :: forall r
   . Writable r
  -> Encoding
  -> String
  -> Effect Unit
  -> Effect Boolean
writeString w enc = writeStringImpl w (show enc)

-- | Force buffering of writes.
foreign import cork :: forall r. Writable r -> Effect Unit

-- | Flush buffered data.
foreign import uncork :: forall r. Writable r -> Effect Unit

foreign import setDefaultEncodingImpl
  :: forall r
   . Writable r
  -> String
  -> Effect Unit

-- | Set the default encoding used to write strings to the stream. This function
-- | is useful when you are passing a writable stream to some other JavaScript
-- | library, which already expects a default encoding to be set. It has no
-- | effect on the behaviour of the `writeString` function (because that
-- | function ensures that the encoding is always supplied explicitly).
setDefaultEncoding
  :: forall r
   . Writable r
  -> Encoding
  -> Effect Unit
setDefaultEncoding r enc = setDefaultEncodingImpl r (show enc)

-- | End writing data to the stream.
foreign import end
  :: forall r
   . Writable r
  -> Effect Unit
  -> Effect Unit

-- | Destroy the stream. It will release any internal resources.
--
-- Added in node 8.0.
foreign import destroy
  :: forall r
   . Stream r
  -> Effect Unit

-- | Destroy the stream and emit 'error'.
--
-- Added in node 8.0.
foreign import destroyWithError
  :: forall r
   . Stream r
  -> Error
  -> Effect Unit
