inherited Progress: TProgress
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Progress'
  ClientHeight = 103
  ClientWidth = 417
  FormStyle = fsStayOnTop
  Position = poDesigned
  ExplicitWidth = 417
  ExplicitHeight = 103
  PixelsPerInch = 96
  TextHeight = 13
  object lblStage: TLabel [0]
    Left = 16
    Top = 10
    Width = 385
    Height = 13
    Anchors = [akLeft, akBottom]
    AutoSize = False
    Caption = 'lblStage'
  end
  object lblSubstage: TLabel [1]
    Left = 16
    Top = 75
    Width = 57
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'lblSubStage'
    Visible = False
    ExplicitTop = 121
  end
  inherited BFMinBRPanel: TPanel
    Left = 410
    Top = 93
    ExplicitLeft = 493
    ExplicitTop = 303
  end
  object pbProgress: TProgressBar
    Left = 16
    Top = 29
    Width = 385
    Height = 40
    Anchors = [akLeft, akBottom]
    TabOrder = 1
    ExplicitTop = 75
  end
end
