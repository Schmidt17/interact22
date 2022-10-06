port module Main exposing (main)

import Browser
import Html exposing (Html, div, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)



-- HELPER DEFINITIONS


attrMin =
    Html.Attributes.min


attrMax =
    Html.Attributes.max



-- MAIN


main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }



-- SUBSCRIPTIONS


port receiveMQTTMessage : (String -> msg) -> Sub msg


port sendMQTTMessage : String -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveMQTTMessage ReceivedMQTTMessage



-- MODEL


type alias Model =
    { sliderValue : Int
    , mqttMessage : String
    }



-- INIT


init : () -> ( Model, Cmd Msg )
init _ =
    let
        model =
            { sliderValue = 0
            , mqttMessage = ""
            }
    in
    ( model, Cmd.none )



-- UPDATE


type Msg
    = SliderChanged String
    | ReceivedMQTTMessage String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SliderChanged newVal ->
            case String.toInt newVal of
                Just newIntVal ->
                    ( { model | sliderValue = newIntVal }
                    , sendMQTTMessage newVal
                    )

                Nothing ->
                    ( model, Cmd.none )

        ReceivedMQTTMessage msgString ->
            let
                newVal =
                    String.toInt msgString

                newSliderValue =
                    case newVal of
                        Just val ->
                            val

                        Nothing ->
                            model.sliderValue
            in
            ( { model | mqttMessage = msgString, sliderValue = newSliderValue }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ input
                [ type_ "range"
                , attribute "orient" "vertical"
                , attrMin "0"
                , attrMax "127"
                , value (String.fromInt model.sliderValue)
                , onInput SliderChanged
                ]
                []
            ]
        , div [] [ text model.mqttMessage ]
        , div [] [ text (String.fromInt model.sliderValue) ]
        ]
