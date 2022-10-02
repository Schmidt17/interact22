port module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import SingleSlider exposing (..)



-- MAIN


main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }



-- SUBSCRIPTIONS


port receiveMQTTMessage : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveMQTTMessage ReceivedMQTTMessage



-- MODEL


type alias Model =
    { singleSlider : SingleSlider.SingleSlider Msg
    , mqttMessage : String
    }



-- INIT


init : () -> ( Model, Cmd Msg )
init _ =
    let
        minFormatter =
            \value -> String.fromFloat value

        model =
            { singleSlider =
                SingleSlider.init
                    { min = 0
                    , max = 127
                    , value = 50
                    , step = 1
                    , onChange = SingleSliderChange
                    }
                    |> SingleSlider.withMinFormatter minFormatter
            , mqttMessage = ""
            }
    in
    ( model, Cmd.none )



-- UPDATE


type Msg
    = SingleSliderChange Float
    | ReceivedMQTTMessage String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SingleSliderChange newVal ->
            let
                newSlider =
                    SingleSlider.update newVal model.singleSlider
            in
            ( { model | singleSlider = newSlider }, Cmd.none )

        ReceivedMQTTMessage msgString ->
            let
                newVal =
                    String.toFloat msgString

                newSlider =
                    case newVal of
                        Just val ->
                            SingleSlider.update val model.singleSlider

                        Nothing ->
                            model.singleSlider
            in
            ( { model | mqttMessage = msgString, singleSlider = newSlider }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [] [ SingleSlider.view model.singleSlider ]
        , div [] [ text model.mqttMessage ]
        ]
