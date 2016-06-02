module Main exposing (..)

import Html.App as App
import Html.Attributes as HA
import Svg as S exposing (Svg, Attribute)
import Svg.Attributes as SA
import Task
import Time exposing (Time)
import Window
import Ease exposing (Easing)
import Button
import Slider


main : Program Never
main =
    App.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { slider : Slider.Model
    , button : Button.Model Msg
    , size : Window.Size
    }


init : ( Model, Cmd Msg )
init =
    ( Model
        (Slider.new
            { easing = Ease.inBack
            , time = Time.second
            , width = 0
            , radius = 10
            , fillColor = fillColor
            }
        )
        (Button.init
            { onPlay = Slider.Start |> SliderMsg
            , onReset = Slider.Reset |> SliderMsg
            }
        )
        (Window.Size 0 0)
    , Task.perform (\_ -> Debug.crash "window has no size?!") Resize Window.size
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ model.button |> Button.subscriptions |> Sub.map ButtonMsg
        , model.slider |> Slider.subscriptions |> Sub.map SliderMsg
        , Window.resizes Resize
        ]



-- UPDATE


type Msg
    = Resize Window.Size
    | SliderMsg Slider.Msg
    | ButtonMsg Button.Msg
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Resize size ->
            { model
                | size = size
                , slider = model.slider |> Slider.setWidth (size.width // 2)
            }
                ! []

        SliderMsg msg ->
            { model | slider = Slider.update msg model.slider } ! []

        ButtonMsg msg ->
            let
                ( newButton, event ) =
                    model.button |> Button.update msg
            in
                { model | button = newButton }
                    |> onButtonEvent event

        NoOp ->
            model ! []


onButtonEvent : Button.Event -> Model -> ( Model, Cmd Msg )
onButtonEvent evt model =
    flip update model
        <| case evt of
            Button.Play ->
                SliderMsg Slider.Start

            Button.Reset ->
                SliderMsg Slider.Reset

            Button.NoEvent ->
                NoOp



-- VIEW


view : Model -> Svg Msg
view model =
    let
        { width, height } =
            model.size

        transform =
            "translate(" ++ toString (width // 2) ++ " " ++ toString (height // 2) ++ ")"

        buttonTransform =
            "translate(0 30) scale(10)"
    in
        S.svg
            [ SA.version "1.1"
            , SA.baseProfile "full"
            , HA.attribute "xmlns" "http://www.w3.org/2000/svg"
            , SA.width <| toString <| width
            , SA.height <| toString <| height
            , SA.transform transform
            , HA.style [ (,) "display" "block" ]
            ]
            [ Slider.view model.slider
            , S.g
                [ SA.transform buttonTransform
                ]
                [ model.button |> Button.view |> App.map ButtonMsg ]
            ]


fillColor : String
fillColor =
    "#DD0000"
