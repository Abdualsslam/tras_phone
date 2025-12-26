import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, MinLength, MaxLength, Matches } from 'class-validator';

export class ChangePasswordDto {
    @ApiProperty({
        example: 'OldStrongP@ss123',
        description: 'Current password',
    })
    @IsString()
    @IsNotEmpty()
    oldPassword: string;

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
