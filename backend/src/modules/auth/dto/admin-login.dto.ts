import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsEmail } from 'class-validator';

export class AdminLoginDto {
    @ApiProperty({
        example: 'admin@trasphone.com',
        description: 'Admin email address'
    })
    @IsEmail({}, { message: 'Email must be a valid email address' })
    @IsNotEmpty()
    email: string;

    @ApiProperty({
        example: 'StrongP@ss123',
        description: 'Admin password'
    })
    @IsString()
    @IsNotEmpty()
    password: string;
}
