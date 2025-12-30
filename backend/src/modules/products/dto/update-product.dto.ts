import { PartialType } from '@nestjs/swagger';
import { CreateProductDto } from './create-product.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Update Product DTO
 * ═══════════════════════════════════════════════════════════════
 */
export class UpdateProductDto extends PartialType(CreateProductDto) {
    // All fields are optional when updating
    // Inherits all fields from CreateProductDto with @IsOptional()
}
