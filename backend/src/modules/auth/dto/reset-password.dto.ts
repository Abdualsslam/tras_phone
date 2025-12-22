import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, MinLength, MaxLength, Matches } from 'class-validator';

export class ResetPasswordDto {
    @ApiProperty({
        example: 'a1b2c3d4e5f6...',
        description: 'Password reset token received after OTP verification',
    })
    @IsString()
    @IsNotEmpty()
    resetToken: string;

    @ApiProperty({
        example: 'NewStrongP@ss123',
        description: 'New password',
    })
    @IsString()
    @IsNotEmpty()
    @MinLength(8)
    @MaxLength(50)
    @Matches(
        /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/,
        {
            message:
                'Password must contain at least one uppercase letter, one lowercase letter, one number and one special character',
        },
    )
    newPassword: string;
}
