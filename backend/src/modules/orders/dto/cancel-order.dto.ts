import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty } from 'class-validator';

export class CancelOrderDto {
  @ApiProperty({
    description: 'Reason for cancellation (required)',
    example: 'Changed my mind',
  })
  @IsString()
  @IsNotEmpty({ message: 'Reason is required' })
  reason: string;
}
