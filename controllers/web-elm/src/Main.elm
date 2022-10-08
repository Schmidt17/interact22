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
    , sliderDisabled : Bool
    }



-- INIT


init : () -> ( Model, Cmd Msg )
init _ =
    let
        model =
            { sliderValue = 0
            , mqttMessage = ""
            , sliderDisabled = True
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
                            { value = val
                            , disabled = False
                            }

                        Nothing ->
                            { value = model.sliderValue
                            , disabled = model.sliderDisabled
                            }
            in
            ( { model
                | mqttMessage = msgString
                , sliderValue = newSliderValue.value
                , sliderDisabled = newSliderValue.disabled
              }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "slider-container" ]
            [ input
                ([ type_ "range"
                 , attribute "orient" "vertical"
                 , attrMin "0"
                 , attrMax "127"
                 , value (String.fromInt model.sliderValue)
                 , onInput SliderChanged
                 ]
                    ++ (if model.sliderDisabled then
                            [ class "disabled"
                            , disabled True
                            ]

                        else
                            []
                       )
                )
                []
            ]
        , div [ class "label-container" ]
            [ div [ class "labels" ]
                [ div [] [ text ("Last MQTT message: " ++ model.mqttMessage) ]
                , div [] [ text ("Current slider value: " ++ String.fromInt model.sliderValue) ]
                , div []
                    [ text
                        ("Slider disabled: "
                            ++ (if model.sliderDisabled then
                                    "True"

                                else
                                    "False"
                               )
                        )
                    ]
                ]
            ]
        ]
