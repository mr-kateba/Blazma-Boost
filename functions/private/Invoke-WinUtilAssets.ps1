function Invoke-WinUtilAssets {
  param (
      $type,
      $Size,
      [switch]$render
  )

  if ($render -and $null -ne $sync) {
      if ($null -eq $sync.RenderedAssetCache) {
          $sync.RenderedAssetCache = [Hashtable]::Synchronized(@{})
      }

      $cacheKey = "$(([string]$type).ToLowerInvariant())|$Size"
      if ($sync.RenderedAssetCache.ContainsKey($cacheKey)) {
          return $sync.RenderedAssetCache[$cacheKey]
      }
  }

  # Create the Viewbox and set its size
  $LogoViewbox = New-Object Windows.Controls.Viewbox
  $LogoViewbox.Width = $Size
  $LogoViewbox.Height = $Size
  # The window lays out right to left for Arabic, which would mirror the drawings
  $LogoViewbox.FlowDirection = [Windows.FlowDirection]::LeftToRight

  # Create a Canvas to hold the paths
  $canvas = New-Object Windows.Controls.Canvas
  $canvas.Width = 100
  $canvas.Height = 100

  # Define a scale factor for the content inside the Canvas
  $scaleFactor = $Size / 100

  # Apply a scale transform to the Canvas content
  $scaleTransform = New-Object Windows.Media.ScaleTransform($scaleFactor, $scaleFactor)
  $canvas.LayoutTransform = $scaleTransform

  switch ($type) {
      'logo' {
          # Blazma Boost logo: an orange hexagon with a white lightning bolt
          $hexagon = New-Object Windows.Shapes.Path
          $hexagon.Data = [Windows.Media.Geometry]::Parse("M 50,3 L 91,26.5 L 91,73.5 L 50,97 L 9,73.5 L 9,26.5 Z")
          $hexagon.Fill = [Windows.Media.LinearGradientBrush]::new(
              [Windows.Media.Color][Windows.Media.ColorConverter]::ConvertFromString("#FFB300"),
              [Windows.Media.Color][Windows.Media.ColorConverter]::ConvertFromString("#FF3D00"),
              [double]90)

          $bolt = New-Object Windows.Shapes.Path
          $bolt.Data = [Windows.Media.Geometry]::Parse("M 57,14 L 27,55 L 46,55 L 40,86 L 73,43 L 54,43 L 61,14 Z")
          $bolt.Fill = [Windows.Media.Brushes]::White

          $canvas.Children.Add($hexagon) | Out-Null
          $canvas.Children.Add($bolt) | Out-Null
      }
      'checkmark' {
          $canvas.Width = 512
          $canvas.Height = 512

          $scaleFactor = $Size / 2.54
          $scaleTransform = New-Object Windows.Media.ScaleTransform($scaleFactor, $scaleFactor)
          $canvas.LayoutTransform = $scaleTransform

          # Define the circle path
          $circlePathData = "M 1.27,0 A 1.27,1.27 0 1,0 1.27,2.54 A 1.27,1.27 0 1,0 1.27,0"
          $circlePath = New-Object Windows.Shapes.Path
          $circlePath.Data = [Windows.Media.Geometry]::Parse($circlePathData)
          $circlePath.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#39ba00")

          # Define the checkmark path
          $checkmarkPathData = "M 0.873 1.89 L 0.41 1.391 A 0.17 0.17 0 0 1 0.418 1.151 A 0.17 0.17 0 0 1 0.658 1.16 L 1.016 1.543 L 1.583 1.013 A 0.17 0.17 0 0 1 1.599 1 L 1.865 0.751 A 0.17 0.17 0 0 1 2.105 0.759 A 0.17 0.17 0 0 1 2.097 0.999 L 1.282 1.759 L 0.999 2.022 L 0.874 1.888 Z"
          $checkmarkPath = New-Object Windows.Shapes.Path
          $checkmarkPath.Data = [Windows.Media.Geometry]::Parse($checkmarkPathData)
          $checkmarkPath.Fill = [Windows.Media.Brushes]::White

          # Add the paths to the Canvas
          $canvas.Children.Add($circlePath) | Out-Null
          $canvas.Children.Add($checkmarkPath) | Out-Null
      }
      'warning' {
          $canvas.Width = 512
          $canvas.Height = 512

          # Define a scale factor for the content inside the Canvas
          $scaleFactor = $Size / 512  # Adjust scaling based on the canvas size
          $scaleTransform = New-Object Windows.Media.ScaleTransform($scaleFactor, $scaleFactor)
          $canvas.LayoutTransform = $scaleTransform

          # Define the circle path
          $circlePathData = "M 256,0 A 256,256 0 1,0 256,512 A 256,256 0 1,0 256,0"
          $circlePath = New-Object Windows.Shapes.Path
          $circlePath.Data = [Windows.Media.Geometry]::Parse($circlePathData)
          $circlePath.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#f41b43")

          # Define the exclamation mark path
          $exclamationPathData = "M 256 307.2 A 35.89 35.89 0 0 1 220.14 272.74 L 215.41 153.3 A 35.89 35.89 0 0 1 251.27 116 H 260.73 A 35.89 35.89 0 0 1 296.59 153.3 L 291.86 272.74 A 35.89 35.89 0 0 1 256 307.2 Z"
          $exclamationPath = New-Object Windows.Shapes.Path
          $exclamationPath.Data = [Windows.Media.Geometry]::Parse($exclamationPathData)
          $exclamationPath.Fill = [Windows.Media.Brushes]::White

          # Get the bounds of the exclamation mark path
          $exclamationBounds = $exclamationPath.Data.Bounds

          # Calculate the center position for the exclamation mark path
          $exclamationCenterX = ($canvas.Width - $exclamationBounds.Width) / 2 - $exclamationBounds.X
          $exclamationPath.SetValue([Windows.Controls.Canvas]::LeftProperty, $exclamationCenterX)

          # Define the rounded rectangle at the bottom (dot of exclamation mark)
          $roundedRectangle = New-Object Windows.Shapes.Rectangle
          $roundedRectangle.Width = 80
          $roundedRectangle.Height = 80
          $roundedRectangle.RadiusX = 30
          $roundedRectangle.RadiusY = 30
          $roundedRectangle.Fill = [Windows.Media.Brushes]::White

          # Calculate the center position for the rounded rectangle
          $centerX = ($canvas.Width - $roundedRectangle.Width) / 2
          $roundedRectangle.SetValue([Windows.Controls.Canvas]::LeftProperty, $centerX)
          $roundedRectangle.SetValue([Windows.Controls.Canvas]::TopProperty, 324.34)

          # Add the paths to the Canvas
          $canvas.Children.Add($circlePath) | Out-Null
          $canvas.Children.Add($exclamationPath) | Out-Null
          $canvas.Children.Add($roundedRectangle) | Out-Null
      }
      default {
          Write-Host "Invalid type: $type"
      }
  }

  # Add the Canvas to the Viewbox
  $LogoViewbox.Child = $canvas

  if ($render) {
      # Measure and arrange the canvas to ensure proper rendering
      $canvas.Measure([Windows.Size]::new($canvas.Width, $canvas.Height))
      $canvas.Arrange([Windows.Rect]::new(0, 0, $canvas.Width, $canvas.Height))
      $canvas.UpdateLayout()

      # Initialize RenderTargetBitmap correctly with dimensions
      $renderTargetBitmap = New-Object Windows.Media.Imaging.RenderTargetBitmap($canvas.Width, $canvas.Height, 96, 96, [Windows.Media.PixelFormats]::Pbgra32)

      # Render the canvas to the bitmap
      $renderTargetBitmap.Render($canvas)

      # Create a BitmapFrame from the RenderTargetBitmap
      $bitmapFrame = [Windows.Media.Imaging.BitmapFrame]::Create($renderTargetBitmap)

      # Create a PngBitmapEncoder and add the frame
      $bitmapEncoder = [Windows.Media.Imaging.PngBitmapEncoder]::new()
      $bitmapEncoder.Frames.Add($bitmapFrame)

      # Save to a memory stream
      $imageStream = New-Object System.IO.MemoryStream
      $bitmapEncoder.Save($imageStream)
      $imageStream.Position = 0

      # Load the stream into a BitmapImage
      $bitmapImage = [Windows.Media.Imaging.BitmapImage]::new()
      $bitmapImage.BeginInit()
      $bitmapImage.StreamSource = $imageStream
      $bitmapImage.CacheOption = [Windows.Media.Imaging.BitmapCacheOption]::OnLoad
      $bitmapImage.EndInit()
      if ($bitmapImage.CanFreeze) {
          $bitmapImage.Freeze()
      }

      if ($null -ne $sync -and $sync.ContainsKey("RenderedAssetCache")) {
          $sync.RenderedAssetCache[$cacheKey] = $bitmapImage
      }

      return $bitmapImage
  } else {
      return $LogoViewbox
  }
}
