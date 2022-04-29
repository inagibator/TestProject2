inherited N_MapEdFrame: TN_MapEdFrame
  Width = 238
  Height = 124
  inherited PaintBox: TPaintBox
    Width = 222
    Height = 108
  end
  inherited HScrollBar: TScrollBar
    Top = 108
    Width = 238
  end
  inherited VScrollBar: TScrollBar
    Left = 222
    Height = 108
  end
  object MapEdFrameActList: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 160
    Top = 8
    object aDebDeb1: TAction
      Caption = 'Debug 1'
      ImageIndex = 128
      OnExecute = aDebDeb1Execute
    end
  end
end
