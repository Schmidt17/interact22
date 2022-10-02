module Main exposing (main)

import Browser
import Html exposing (Html, div)
import SingleSlider exposing (..)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { singleSlider : SingleSlider.SingleSlider Msg }



-- INIT


init : Model
init =
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
            }
    in
    model



-- UPDATE


type Msg
    = SingleSliderChange Float


update : Msg -> Model -> Model
update msg model =
    case msg of
        SingleSliderChange newVal ->
            let
                newSlider =
                    SingleSlider.update newVal model.singleSlider
            in
            { model | singleSlider = newSlider }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [] [ SingleSlider.view model.singleSlider ]
        ]
